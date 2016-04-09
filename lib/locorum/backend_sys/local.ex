defmodule Locorum.BackendSys.Local do
  require Logger
  # alias Locorum.BackendSys.Result
  # alias Locorum.BackendSys.Header

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    get_url(query.city, query.state, query.biz)
    |> fetch_html()
  end

  defp fetch_html(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        [headers|_] = headers
        headers = elem(headers, 1)
        fetch_html(get_url(headers))
      # TODO: Determine if we need these error reports or not? Maybe just let it crash?
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("404 redirect, Local backend, #{inspect url}")
        {:error, "404"}
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Logger.error("403 redirect, Local backend, #{inspect url}")
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect reason}, Local backend, #{inspect url}")
        {:error, reason}
    end
  end

  defp get_url(city, state, biz) do
    city =
      city
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "%2520")
    state = String.downcase(state)
    biz =
      biz
      |> String.downcase
      |> String.replace(~r/[^\w-]+/, "%20")

    "http://www.local.com/business/results/?keyword=#{biz}&location=#{city}%252C%2520#{state}"
  end
  defp get_url(redirect) do
    "http://www.local.com#{redirect}"
  end

  def parse_data(body) do
    address = parse_item(Floki.find(body, "span.street-address"))
    [city, state] =
      parse_item(Floki.find(body, "span.locality"))
      |> parse_city_state
    # List.zip([address, List.zip(location)])
    List.zip([address, city, state])
  end

  defp parse_item([]), do: []
  defp parse_item([{_,[{_,_}],[item]} | tail]), do: [String.strip(item) | parse_item(tail)]
  defp parse_item([{_,[{_,_},{_,_}],[item]} | tail]), do: [String.strip(item) | parse_item(tail)]
  # defp parse_item(blank), do: blank

  def parse_city_state(initial_value), do: parse_city_state(initial_value, [], [])
  def parse_city_state([head|tail], city, state) do
    [new_city|new_state] = String.split(head, ", ")
    parse_city_state(tail, city ++ [new_city], state ++ new_state)
  end
  def parse_city_state([], city, state), do: [city, state]
end
