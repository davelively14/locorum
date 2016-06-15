defmodule Locorum.BackendSys.Neustar do
  alias Locorum.BackendSys.Helpers
  # alias Locorum.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_html
  end

  def get_url(query) do
    city =
      query.city
      |> Helpers.convert_to_utf("+")

    state = query.state

    biz =
      query.biz
      |> Helpers.convert_to_utf("+")

    "https://www.neustarlocaleze.biz/directory/us?Name=#{biz}&Location=#{city}+#{state}"
  end
end
