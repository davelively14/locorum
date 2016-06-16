defmodule Locorum.BackendSys.Facebook do
  alias Locorum.BackendSys.Helpers
  # alias Locorum.BackendSys.Result

  @default_distance 30_000

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    query
    |> get_url
  end

  def get_url(query) do
    name =
      query.biz
      |> Helpers.convert_to_utf("+")
    distance = @default_distance
    geocode = Helpers.geocode(query.zip)

    "https://graph.facebook.com/v2.6/search?q=#{name}&type=place&center=#{geocode["lat"]},#{geocode["lng"]}&distance=#{distance}"
  end
end
