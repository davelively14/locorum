defmodule Locorum.BackendSys.Helpers do
  use Phoenix.Channel
  alias Locorum.Result
  alias Locorum.Repo
  alias Locorum.Backend
  alias Locorum.BackendSys.Header
  require Logger

  @max_stored_results 3

  def join(_,_,_), do: nil

  def get_backend(mod) do
    Locorum.Backend
    |> Repo.get_by(module: Atom.to_string(mod))
  end

  def display_results(results, mod, socket, query, url) do
    set_header(url, get_backend(mod), query)
    |> init_frontend(socket)

    # TODO Sleep for 1/2 a second? There has to be a better way to ensure this executes in order.
    :timer.sleep(500)

    rate_results(results, query)
    |> sort_results
    |> broadcast_results(get_backend(mod), socket, query)
  end

  def init_json(url, mod, socket, query) do
    set_header(url, get_backend(mod), query)
    |> init_frontend(socket)
    |> fetch_json
  end

  def init_html(url, mod, socket, query) do
    set_header(url, get_backend(mod), query)
    |> init_frontend(socket)
    |> fetch_html
  end

  def send_results(results, mod, socket, query) do
    rate_results(results, query)
    |> sort_results
    |> broadcast_results(get_backend(mod), socket, query)
  end

  def convert_to_utf(text, output) do
    String.downcase(text)
    |> String.replace("'", "%27")
    |> String.replace(~r/[^\w-'^%]+/, output)
  end

  # TODO delete this?Added TODO
  def pop_first([_head|tail], current) when current > 0, do: pop_first(tail, current - 1)
  def pop_first(remaining, _current), do: remaining

  def rate_results(results, query) do
    address = single_address(query.address1, query.address2)

    for result <- results do
      rating =
        %{biz: rate_same(result.biz, query.biz), address: rate_same(result.address, address),
          city: rate_same(result.city, query.city), state: rate_same(result.state, query.state),
          phone: rate_same(phonify(result.phone), phonify(query.phone))}
        |> return_lowest

      cond do
        result.zip && (result.zip != query.zip) ->
          rating = 0.2
        result.phone && (phonify(result.phone) != phonify(query.phone)) ->
          rating = 0.5
        true ->
          nil
      end

      # if (result.zip && (result.zip != query.zip)) || (result.phone && (phonify(result.phone) != phonify(query.phone)) do
      #   rating = 20
      # end
      Map.put(result, :rating, round(rating * 100))
    end
  end

  def geocode(zip) do
    "https://maps.googleapis.com/maps/api/place/textsearch/json?key=#{get_key}&query=#{zip}"
    |> fetch_json
    |> Poison.decode!
    |> Map.get("results")
    |> List.first
    |> Map.get("geometry")
    |> Map.get("location")
  end

  def get_key, do: Application.get_env(:locorum, :google)[:key]

  defp rate_same(string1, string2) do
    if string1 && string2 do
      string1 = String.upcase(string1)
      string2 = String.upcase(string2)
      String.jaro_distance(string1, string2)
    else
      nil
    end
  end

  defp sort_results(map), do: Enum.sort(map, &(&1.rating > &2.rating))

  defp return_lowest(map) do
    Map.values(map)
    |> return_lowest(1.0)
  end
  defp return_lowest([], lowest), do: lowest
  defp return_lowest([head|tail], lowest) when head < lowest, do: return_lowest(tail, head)
  defp return_lowest([_head|tail], lowest), do: return_lowest(tail, lowest)

  defp single_address(address1, address2) do
    case address2 do
      nil -> address1
      _ -> "#{address1}, #{address2}"
    end
  end

  defp phonify(phone_number) do
    if phone_number do
      String.replace(phone_number, ~r/[^\w]/, "")
      |> String.slice(phone_number, (String.length(phone_number)-10)..(String.length(phone_number)-1))
    else
      phone_number
    end
  end

  defp broadcast_results(results, backend, socket, query) do
    header = set_header(nil, backend, query)
    if results != [] do
      for result <- results do
        collect_result(result, header, socket.assigns.result_collection_id)

        broadcast! socket, "result", %{
          backend: header.backend,
          biz: result.biz,
          address: result.address,
          city: result.city,
          state: result.state,
          zip: result.zip,
          rating: result.rating,
          url: result.url,
          phone: result.phone,
          search_id: query.id
        }
      end

      broadcast! socket, "loaded_results", %{
        backend: header.backend,
        backend_str: header.backend_str,
        search_id: query.id,
        num_results: Enum.count(results),
        high_rating: Integer.to_string(List.first(results).rating),
        low_rating: Integer.to_string(List.last(results).rating)
      }
    else
      broadcast! socket, "no_result", %{
        backend: header.backend
      }
      broadcast! socket, "loaded_results", %{
        backend: header.backend,
        backend_str: header.backend_str,
        search_id: query.id,
        num_results: 0,
        high_rating: "--",
        low_rating: "--"
      }
    end
  end

  defp set_header(url, backend, query) do
    %Header{
      backend: backend.name,
      backend_str: backend.name_str,
      url_site: backend.url,
      url_search: url,
      search_id: query.id
    }
  end

  def fetch_json(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: json}} ->
        json
      {:ok, %HTTPoison.Response{status_code: 301}} ->
        Logger.error("301 redirect, #{__MODULE__} backend, #{inspect url}. Change get call to url, [], follow_redirect: true")
        {:error, "301"}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, #{__MODULE__} backend, #{inspect url}")
        {:error, reason}
      {:ok, %HTTPoison.Response{body: json}} ->
        json
    end
  end

  def fetch_html(url) do
    case HTTPoison.get(url, [], follow_redirect: true, hackney: [:insecure]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: html}} ->
        html
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, #{__MODULE__} backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, #{__MODULE__} backend, #{inspect url}")
        {:error, reason}
      {:ok, %HTTPoison.Response{body: html}} ->
          html
    end
  end

  defp collect_result(result, header, collection_id) do
    backend = Repo.get_by(Backend, name: header.backend)

    changeset = Result.changeset(%Result{backend_id: backend.id, result_collection_id: collection_id}, %{
        name: result.biz,
        address: result.address,
        city: result.city,
        state: result.state,
        zip: result.zip,
        rating: Integer.to_string(result.rating),
        phone: result.phone,
        url: result.url
      })

    case Repo.insert(changeset) do
      {:ok, _result} ->
        nil
      {:error, changeset} ->
        for error <- changeset.errors do
          IO.inspect(error)
        end
    end
  end

  defp init_frontend(header, socket) do
    broadcast! socket, "backend", %{
      backend: header.backend,
      backend_str: header.backend_str,
      backend_url: header.url_site,
      url: header.url_search,
      search_id: header.search_id
    }
    header.url_search
  end
end
