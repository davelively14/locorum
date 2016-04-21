defmodule Locorum.BackendSys.Bing do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Header
  # alias Locorum.BackendSys.Result

  @backend %Header{backend: "bing", backend_str: "Bing", url_site: "https://www.bing.com/"}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    get_url(query)
  end

  def get_url(query) do
    city =
      query.city
      |> Helpers.convert_to_utf("%20")
    state = query.state
    address =
      query.address1
      |> Helpers.convert_to_utf("%20")
    zip = query.zip

    "http://dev.virtualearth.net/REST/v1/Locations/US/#{state}/#{zip}/#{city}/#{address}?o=json&key=#{key_id}"
  end

  defp key_id, do: Application.get_env(:locorum, :bing)[:key]
end
