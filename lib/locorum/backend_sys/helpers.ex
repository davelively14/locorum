defmodule Locorum.BackendSys.Helpers do
  use Phoenix.Channel, only: [broadcast!: 3]
  alias Locorum.{Result, Repo, Backend, BackendSys.Header, ProjectChannelServer}
  require Logger

  def join(_,_,_), do: nil

  def get_backend(mod) do
    Locorum.Backend
    |> Repo.get_by(module: Atom.to_string(mod))
  end

  def display_results(results, mod, socket, query, url) do
    rate_results(results, query)
    |> sort_results
    |> send_results_to_server(get_backend(mod), socket, query, url)
  end

  def convert_to_utf(text, output) do
    String.downcase(text)
    |> String.replace("'", "%27")
    |> String.replace(~r/[^\w-'^%]+/, output)
  end

  def rate_results(results, query) do
    address = single_address(query.address1, query.address2)

    for result <- results do
      rating =
        %{biz: rate_same(result.biz, query.biz), address: rate_same(result.address, address),
          city: rate_same(result.city, query.city), state: rate_same(result.state, query.state),
          phone: rate_same(phonify(result.phone), phonify(query.phone))}
        |> return_lowest

      rating =
        cond do
          result.zip && (result.zip != query.zip) ->
            0.2
          result.phone && (phonify(result.phone) != phonify(query.phone)) ->
            0.5
          true ->
            rating
        end

      Map.put(result, :rating, round(rating * 100))
    end
  end

  # Gets a geolocation based on a zip code.
  def geocode(zip) do
    Locorum.ZipLocate.get_data
    |> Map.get(zip)
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

  # Stores each result in the Repo and then sends the results back to the
  # ProjectChannelServer, which will distribute them to the channel.
  defp send_results_to_server(results, backend, socket, query, url) do

    # Get header information.
    header = set_header(url, backend, query)

    if results != [] do

      # Store and collect the results to be added to the payload sent to the
      # server. Will return a list of result objects
      return_results =
        for result <- results do

          # Calls store_result/3, which will put result in the repo
          store_result(result, header, socket.assigns.result_collection_id)

          %{
            user_id: socket.assigns.user_id,
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

      # Formulates the message to be sent to the channel with a results summary
      loaded_message = %{
        user_id: socket.assigns.user_id,
        backend: header.backend,
        backend_str: header.backend_str,
        results_url: url,
        search_id: query.id,
        num_results: Enum.count(results),
        high_rating: Integer.to_string(List.first(results).rating),
        low_rating: Integer.to_string(List.last(results).rating)
      }

      payload = %{results: return_results, loaded_message: loaded_message}

      GenServer.cast(ProjectChannelServer.name(socket.assigns.project_id), {:receive_result, socket, payload})
    else
      no_result = %{
        user_id: socket.assigns.user_id,
        backend: header.backend,
        search_id: query.id
      }

      loaded_message = %{
        user_id: socket.assigns.user_id,
        backend: header.backend,
        backend_str: header.backend_str,
        search_id: query.id,
        num_results: 0,
        high_rating: "--",
        low_rating: "--"
      }

      payload = %{no_result: no_result, loaded_message: loaded_message}

      GenServer.cast(ProjectChannelServer.name(socket.assigns.project_id), {:no_result, socket, payload})
    end
  end

  # Sets header information to be used in the results sent back to the server.
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

  defp store_result(result, header, collection_id) do
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

  # defp init_frontend(header, socket) do
  #   broadcast! socket, "backend", %{
  #     backend: header.backend,
  #     backend_str: header.backend_str,
  #     backend_url: header.url_site,
  #     url: header.url_search,
  #     search_id: header.search_id
  #   }
  #   header.url_search
  # end
end
