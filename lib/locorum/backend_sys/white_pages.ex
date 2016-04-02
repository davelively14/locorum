defmodule Locorum.BackendSys.WhitePages do

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
  end

  defp get_url(city, state, biz) do
    "http://www.whitepages.com/business/" <> String.upcase(state) <> "/" <> city <> "/" <> biz
  end

  defp pull_data(city, state, biz) do
    case HTTPoison.get(get_url(city, state, biz)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def test_pull() do
    pull_data("atlanta", "GA", "lucas-group")
  end
end
