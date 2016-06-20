defmodule Locorum.BackendSys.Mapquest do
  alias Locorum.BackendSys.Helpers
  # alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_html
    |> parse_data
  end

  def get_url(query) do
    name = query.biz |> Helpers.convert_to_utf("%20")
    state = query.state
    city = query.city |> Helpers.convert_to_utf("%20")

    "https://www.mapquest.com/search/results?page=0&query=#{name}%20#{city}%20#{state}"
  end

  def parse_data(body) do
    focus = body |> Floki.find("script[id=SearchResults]") |> List.first |> elem(2) |> List.first |> Poison.decode!
    focus
  end
end
