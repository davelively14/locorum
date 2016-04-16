defmodule Locorum.BackendSys.WhitePages do
  require Logger
  alias Locorum.BackendSys.Result
  alias Locorum.BackendSys.Header

  @backend_url "http://www.whitepages.com/"

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, _limit) do
    get_url(query.city, query.state, query.biz)
    |> fetch_html
    |> parse_data
    |> send_results(query_ref, owner, get_url(query.city, query.state, query.biz))
  end

  defp fetch_html(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, White Pages backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, White Pages backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, White Pages backend, #{inspect url}")
        {:error, reason}
    end
  end

  def parse_data(body) do
    name = parse_item(Floki.find(body, "p[itemprop=name]"))
    address = parse_item(Floki.find(body, "span[itemprop=streetAddress]"))
    city = parse_item(Floki.find(body, "span[itemprop=addressLocality]"))
    state = parse_item(Floki.find(body, "span[itemprop=addressRegion]"))
    zip = parse_item(Floki.find(body, "span[itemprop=postalCode]"))

    add_to_result(List.zip([name, address, city, state, zip]))
  end

  defp get_url(city, state, biz) do
    city =
      city
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "-")
    biz =
      biz
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "-")
    "http://www.whitepages.com/business/" <> String.upcase(state) <> "/" <> city <> "/" <> biz
  end

  # TODO create a backendContainer with information on search
  defp send_results(nil, query_ref, owner, _url), do: send(owner, {:ignore, query_ref, []})
  # TODO send the header information separate, allow search_channel to prepare the backend container
  # TODO send each result separately back to the search channel
  defp send_results(results, query_ref, owner, url) do
    send(owner, {:results, query_ref, %Header{backend: "white_pages", url_search: url, url_site: @backend_url}, results})
  end

  defp parse_item([]), do: []
  defp parse_item([{_, _,[item]} | tail]), do: [String.strip(item) | parse_item(tail)]

  defp add_to_result([]), do: []
  defp add_to_result([{name, address, city, state, zip} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip } | add_to_result(tail)]
  end
end
