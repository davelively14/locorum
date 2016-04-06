defmodule Locorum.BackendSys.WhitePages do
  alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, query_ref, owner, _limit) do
    city = query.city
    state = query.state
    biz =
      query.biz
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "-")

    fetch_html(city, state, biz)
    |> parse_data()
    |> send_results(query_ref, owner)
  end

  defp fetch_html(city, state, biz) do
    case HTTPoison.get(get_url(city, state, biz)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      # TODO: Determine if we need these error reports or not? Maybe just log?
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
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
    "http://www.whitepages.com/business/" <> String.upcase(state) <> "/" <> city <> "/" <> biz
  end

  defp send_results(nil, query_ref, owner), do: send(owner, {:results, query_ref, []})
  defp send_results(results, query_ref, owner) do
    send(owner, {:results, query_ref, results})
  end

  defp parse_item([]), do: []
  defp parse_item([{_,[{_,_}],[item]} | tail]), do: [item | parse_item(tail)]
  defp parse_item([{_,[{_,_},{_,_}],[item]} | tail]), do: [item | parse_item(tail)]

  defp add_to_result([]), do: []
  defp add_to_result([{name, address, city, state, zip} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip, backend: "White Pages" } | add_to_result(tail)]
  end
end
