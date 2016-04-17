defmodule Locorum.BackendSys.Yahoo do
  require Logger
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header

  @backend_url "https://local.yahoo.com"
  @backend "yahoo"
  @backend_str "Yahoo Local"

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, _limit) do
    get_url(query)
    |> fetch_json
    |> parse_data
    |> send_results(query_ref, owner, get_url(query))
  end

  defp get_url(query) do
    zip = query.zip
    biz =
      query.biz
      |> String.replace(~r/[^\w-]+/, "%20")

    "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20local.search%20where%20zip%3D'#{zip}'%20and%20query%3D'#{biz}'&format=json&callback="
  end

  defp fetch_json(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: json}} ->
        json
      {:ok, %HTTPoison.Response{status_code: 301}} ->
        Logger.error("301 redirect, Yahoo backend, #{inspect url}")
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, Yahoo backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, Yahoo backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, Yahoo backend, #{inspect url}")
        {:error, reason}
    end
  end

  defp parse_data(json) do
    result = Poison.decode!(json)
    add_to_result(result["query"]["results"]["Result"])
  end

  defp add_to_result([]), do: []
  defp add_to_result([head|tail]) do
    [%Result{biz: head["Title"], address: head["Address"], city: head["City"], state: head["State"]} | add_to_result(tail)]
  end

  # TODO handle nil results
  defp send_results(nil, query_ref, owner, url), do: send(owner, {:ignore, query_ref, url})
  defp send_results(results, query_ref, owner, url) do
    send(owner, {:results, query_ref, %Header{backend: @backend, backend_str: @backend_str, url_search: url, url_site: @backend_url}, results})
  end
end
