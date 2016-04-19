defmodule Locorum.BackendSys.Yahoo do
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Helpers

  @backend %Header{backend: "yahoo", backend_str: "Yahoo Local", url_site: "http://local.yahoo.com"}

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.fetch_json
    |> parse_data
    |> Helpers.make_message(query_ref, @backend, get_url(query))
    |> Helpers.send_results(owner)
  end

  def get_url(query) do
    zip = query.zip
    biz =
      query.biz
      |> String.replace(~r/[^\w-]+/, "%20")

    "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20local.search%20where%20zip%3D'#{zip}'%20and%20query%3D'#{biz}'&format=json&callback="
  end

  def parse_data(json) do
    result = Poison.decode!(json)
    add_to_result(result["query"]["results"]["Result"])
  end

  defp add_to_result([]), do: []
  defp add_to_result([head|tail]) do
    [%Result{biz: head["Title"], address: head["Address"], city: head["City"], state: head["State"]} | add_to_result(tail)]
  end
  defp add_to_result(single_result) do
    [%Result{biz: single_result["Title"], address: single_result["Address"], city: single_result["City"], state: single_result["State"]}]
  end
end
