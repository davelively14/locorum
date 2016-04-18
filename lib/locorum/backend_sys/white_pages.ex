defmodule Locorum.BackendSys.WhitePages do
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Helpers

  @backend_url "http://www.whitepages.com/"
  @backend "white_pages"
  @backend_str "White Pages"

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.fetch_html
    |> parse_data
    |> send_results(query_ref, owner, get_url(query))
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

  # TODO handle nil results
  defp send_results(nil, query_ref, owner, _url), do: send(owner, {:ignore, query_ref, []})
  defp send_results(results, query_ref, owner, url) do
    send(owner, {:results, query_ref, %Header{backend: @backend, backend_str: @backend_str, url_search: url, url_site: @backend_url}, results})
  end

  defp parse_item([]), do: []
  defp parse_item([{_, _,[item]} | tail]), do: [String.strip(item) | parse_item(tail)]

  defp add_to_result([]), do: []
  defp add_to_result([{name, address, city, state, zip} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip } | add_to_result(tail)]
  end
end
