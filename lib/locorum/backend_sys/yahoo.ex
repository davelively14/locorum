defmodule Locorum.BackendSys.Yahoo do
  require Logger
  # alias Locorum.BackendSys.Result
  # alias Locorum.BackendSys.Header

  @backend_url "https://local.yahoo.com"
  @backend "yahoo"
  @backend_str "Yahoo Local"

  def start_link(query, query_ref, owner, limit) do
    HTTPoison.start
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    get_url(query)
  end

  def get_url(query) do
    zip = query.zip
    biz =
      query.biz
      |> String.replace(~r/[^\w-]+/, "%20")

    "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20local.search%20where%20zip%3D'#{zip}'%20and%20query%3D'#{biz}'&format=json&callback="
  end


end
