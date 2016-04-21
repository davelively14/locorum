defmodule Locorum.BackendSys.Bing do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Header
  # alias Locorum.BackendSys.Result

  @backend %Header{backend: "bing", backend_str: "Bing", url_site: "https://www.bing.com/"}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    get_url(query)
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

    "http://www.bing.com/search?q=#{biz}+#{city}+#{state}"
  end

  defp key_id, do: Application.get_env(:locorum, :bing)[:key]
end
