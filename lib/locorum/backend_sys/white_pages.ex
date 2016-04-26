defmodule Locorum.BackendSys.WhitePages do
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Helpers

  @backend %Header{backend: "white_pages", backend_str: "White Pages", url_site: "http://www.whitepages.com/"}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.init_html(@backend, owner)
    |> parse_data
    |> Helpers.send_results(@backend, owner, query)
  end

  def parse_data(body) do
    name = parse_item(Floki.find(body, "p[itemprop=name]"))
    address = parse_item(Floki.find(body, "span[itemprop=streetAddress]"))
    city = parse_item(Floki.find(body, "span[itemprop=addressLocality]"))
    state = parse_item(Floki.find(body, "span[itemprop=addressRegion]"))
    zip = parse_item(Floki.find(body, "span[itemprop=postalCode]"))
    phone = parse_item(Floki.find(body, "span[itemprop=telephone]"))
    url = parse_url(Floki.find(body, "span[itemprop=shortId]"))

    add_to_result(List.zip([name, address, city, state, zip, phone, url]))
  end

  defp get_url(query) do
    city =
      query.city
      |> Helpers.convert_to_utf("-")
    state = String.upcase(query.state)
    biz =
      query.biz
      |> Helpers.convert_to_utf("-")

    "http://www.whitepages.com/business/" <> state <> "/" <> city <> "/" <> biz
  end

  defp parse_item([]), do: []
  defp parse_item([{_, _,[item]} | tail]), do: [String.strip(item) | parse_item(tail)]

  defp parse_url([]), do: []
  defp parse_url([{_, _,[item]} | tail]), do: ["http://www.whitepages.com/business/#{item}" | parse_url(tail)]

  defp add_to_result([]), do: []
  defp add_to_result([{name, address, city, state, zip, phone, url} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip, phone: phone, url: url } | add_to_result(tail)]
  end
end
