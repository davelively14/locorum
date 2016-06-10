defmodule Locorum.BackendSys.Yahoo do
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Helpers

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.init_json(__MODULE__, owner, query)
    |> parse_data
    |> Helpers.send_results(__MODULE__, owner, query)
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
    [%Result{biz: head["Title"], address: head["Address"], city: head["City"],
             state: head["State"], url: head["Url"], phone: head["Phone"]} | add_to_result(tail)]
  end
  defp add_to_result(single_result) do
    [%Result{biz: single_result["Title"], address: single_result["Address"], city: single_result["City"],
             state: single_result["State"], url: single_result["Url"], phone: single_result["Phone"]}]
  end
end
