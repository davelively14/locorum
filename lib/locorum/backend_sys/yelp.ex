defmodule Locorum.BackendSys.Yelp do
  alias Locorum.BackendSys.Helpers
  # alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    query
    |> get_url
  end

  def get_url(query) do
    city = query.city |> Helpers.convert_to_utf("+")
    state = query.state
    name = query.biz |> Helpers.convert_to_utf("+")

    "https://www.yelp.com/search?find_desc=#{name}&find_loc=#{city}+#{state}"
  end
end
