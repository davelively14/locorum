defmodule Locorum.BackendSys.Helpers do
  use Phoenix.Channel
  require Logger

  def join(_,_,_), do: nil

  def init_json(url, header, socket, query) do
    set_header(url, header, query)
    |> init_frontend(socket)
    |> fetch_json
  end

  def init_html(url, header, socket, query) do
    set_header(url, header, query)
    |> init_frontend(socket)
    |> fetch_html
  end

  def send_results(results, header, socket, query) do
    rate_results(results, query)
    |> sort_results
    |> broadcast_results(header, socket)
  end

  def convert_to_utf(text, output) do
    String.downcase(text)
    |> String.replace(~r/[^\w-']+/, output)
  end

  def pop_first([_head|tail], current) when current > 0, do: pop_first(tail, current - 1)
  def pop_first(remaining, _current), do: remaining

  defp rate_results(results, query) do
    address = single_address(query.address1, query.address2)

    for result <- results do
      rating = %{biz: rate_same(result.biz, query.biz), address: rate_same(result.address, address),
                city: rate_same(result.city, query.city), state: rate_same(result.state, query.state),
                phone: rate_same(phonify(result.phone), phonify(query.phone))}

      rating = return_lowest(rating)
      if result.zip && (result.zip != query.zip) do
        rating = 0
      end
      Map.put(result, :rating, round(rating * 100))
    end
  end

  defp rate_same(string1, string2) do
    string1 = String.upcase(string1)
    string2 = String.upcase(string2)
    String.jaro_distance(string1, string2)
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

  defp phonify(string) do
    string = String.replace(string, ~r/[^\w]/, "")
    String.slice(string, (String.length(string)-10)..(String.length(string)-1))
  end

  defp broadcast_results(results, header, socket) do
    if results != [] do
      for result <- results do
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
          search_id: header.search_id
        }
      end
    else
      broadcast! socket, "no_result", %{
        backend: header.backend
      }
    end
    broadcast! socket, "loaded_results", %{
      backend: header.backend,
      backend_str: header.backend_str
    }
  end

  defp set_header(url, header, query) do
    Map.put(header, :url_search, url)
    |> Map.put(:search_id, query.id)
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
    case HTTPoison.get(url, [], follow_redirect: true) do
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

  # defp make_message(results, query_ref, header) do
  #   {:results, query_ref, header, results}
  # end

  defp init_frontend(header, socket) do
    broadcast! socket, "backend", %{
      backend: header.backend,
      backend_str: header.backend_str,
      backend_url: header.url_site,
      results_url: header.url_search,
      search_id: header.search_id
    }
    header.url_search
  end
end
