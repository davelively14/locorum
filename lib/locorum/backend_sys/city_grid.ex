defmodule Locorum.BackendSys.CityGrid do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_json
    |> parse_data
    |> Helpers.display_results(__MODULE__, owner, query, get_url(query))
  end

  def get_url(query) do
    biz =
      query.biz
      |> Helpers.convert_to_utf("+")
    zip = query.zip

    "http://api.citygridmedia.com/content/places/v2/search/where?what=#{biz}&where=#{zip}&format=json&publisher=test"
  end

  def parse_data(body) do
    result = Poison.decode!(body)
    result["results"]["locations"]
    |> add_to_result
  end

  defp add_to_result([]), do: []
  defp add_to_result([head|tail]) do
    [%Result{biz: head["name"], address: head["address"]["street"], city: head["address"]["city"],
             state: head["address"]["state"], zip: head["address"]["postal_code"],
             phone: head["phone_number"], url: head["profile"]} | add_to_result(tail)]
  end
end
