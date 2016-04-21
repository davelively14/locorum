defmodule Locorum.BackendSys.Google do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Result

  @backend %Header{backend: "google", backend_str: "google_str", url_site: "https://www.google.com"}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    query.city
  end

  def get_url(query) do
    city =
      query.city
      |> Helpers.convert_to_utf("%20")
    state = query.state
    biz =
      query.biz
      |> Helpers.convert_to_utf("%20")

    "https://maps.googleapis.com/maps/api/place/textsearch/json?key=#{get_key}&query=nebo%20agency%20atlanta%20ga"
  end

  defp get_key, do: Application.get_env(:locorum, :google)[:key]
end
