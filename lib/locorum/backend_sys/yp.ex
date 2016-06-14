defmodule Locorum.BackendSys.Yp do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    query
    |> get_url
    |> Helpers.init_json(__MODULE__, owner, query)
    |> parse_data
    |> Helpers.send_results(__MODULE__, owner, query)
  end

  def get_url(query) do
    biz =
      query.biz
      |> Helpers.convert_to_utf("+")
    zip = query.zip

    "http://pubapi.yp.com/search-api/search/devapi/search?searchloc=#{zip}&term=#{biz}&format=json&listingcount=10&key=#{get_key}"
  end

  defp get_key, do: Application.get_env(:locorum, :yp)[:key]

  def parse_data(body) do
    result = Poison.decode!(body)
    add_to_results(result["searchResult"]["searchListings"]["searchListing"])
  end

  defp add_to_results([]), do: []
  defp add_to_results([head|tail]) do
    [%Result{biz: head["businessName"], address: head["street"], zip: Integer.to_string(head["zip"]),
             state: head["state"], city: head["city"], url: head["businessNameURL"],
             phone: head["phone"]} | add_to_results(tail)]
  end
end
