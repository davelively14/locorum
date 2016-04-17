defmodule Locorum.BackendSys.Yahoo do
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Helpers

  @backend_url "https://local.yahoo.com"
  @backend "yahoo"
  @backend_str "Yahoo Local"

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.fetch_json
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
