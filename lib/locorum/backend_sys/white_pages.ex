defmodule Locorum.BackendSys.WhitePages do
  alias Locorum.Search

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    city = query.city
    state = query.state
    biz =
      query.biz
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "-")

    pull_data(city, state, biz)
    |> parse_data()
  end

  defp get_url(city, state, biz) do
    "http://www.whitepages.com/business/" <> String.upcase(state) <> "/" <> city <> "/" <> biz
  end

  defp pull_data(city, state, biz) do
    case HTTPoison.get(get_url(city, state, biz)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def parse_data(body) do
    [{_,[{_,_},{_,_}],[name]}] = Floki.find(body, "p[itemprop=name]")
    [{_,[{_,_}],[address]}] = Floki.find(body, "span[itemprop=streetAddress]")
    [{_,[{_,_}],[city]}] = Floki.find(body, "span[itemprop=addressLocality]")
    [{_,[{_,_}],[state]}] = Floki.find(body, "span[itemprop=addressRegion]")
    [{_,[{_,_}],[zip]}] = Floki.find(body, "span[itemprop=postalCode]")
    %Search{biz: name, address1: address, city: city, state: state, zip: zip }
  end

  def test_pull() do
    pull_data("atlanta", "GA", "lucas-group")
  end
end
