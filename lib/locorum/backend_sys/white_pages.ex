defmodule Locorum.BackendSys.WhitePages do
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Helpers

  @backend %Header{backend: "white_pages", backend_str: "White Pages", url_site: "http://www.local.com"}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.set_header(@backend)
    |> Helpers.init_backend(owner)
    |> Helpers.fetch_html
    |> parse_data
    |> Helpers.send_results(@backend, owner)
  end

  def parse_data(body) do
    name = parse_item(Floki.find(body, "p[itemprop=name]"))
    address = parse_item(Floki.find(body, "span[itemprop=streetAddress]"))
    city = parse_item(Floki.find(body, "span[itemprop=addressLocality]"))
    state = parse_item(Floki.find(body, "span[itemprop=addressRegion]"))
    zip = parse_item(Floki.find(body, "span[itemprop=postalCode]"))

    add_to_result(List.zip([name, address, city, state, zip]))
  end

  defp get_url(query) do
    city =
      query.city
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "-")
    state = String.upcase(query.state)
    biz =
      query.biz
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "-")

    "http://www.whitepages.com/business/" <> state <> "/" <> city <> "/" <> biz
  end

  defp parse_item([]), do: []
  defp parse_item([{_, _,[item]} | tail]), do: [String.strip(item) | parse_item(tail)]

  defp add_to_result([]), do: []
  defp add_to_result([{name, address, city, state, zip} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip } | add_to_result(tail)]
  end
end
