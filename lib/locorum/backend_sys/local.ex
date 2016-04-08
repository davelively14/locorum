defmodule Locorum.BackendSys.Local do
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

  def fetch_html(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      # TODO: Determine if we need these error reports or not? Maybe just let it crash?
      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        [headers|_] = headers
        headers = elem(headers, 1)
        HTTPoison.get(get_url(headers))
      {:ok, %HTTPoison.Response{status_code: 403}} ->
        {:error, "403"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def get_url(city, state, biz) do
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
  def get_url(redirect) do
    "http://www.local.com#{redirect}"
  end
end
