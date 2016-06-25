defmodule Locorum.BackendSys.Facebook do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

  @default_distance 30_000

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_json
    |> parse_data
    |> Helpers.display_results(__MODULE__, owner, query, get_url(query))
  end

  def get_url(query) do
    name =
      query.biz
      |> Helpers.convert_to_utf("+")
    distance = @default_distance
    geocode = Helpers.geocode(query.zip)

    "https://graph.facebook.com/v2.6/search?q=#{name}&type=place&center=#{geocode["lat"]},#{geocode["lng"]}&distance=#{distance}&fields=name,link,location,phone,category&#{get_token}"
  end

  def parse_data(body) do
    data =
      body
      |> Poison.decode!
      |> Map.get("data")
      |> Enum.map(&(if &1["category"] == "Local business", do: &1))
      |> remove_nil_entries

    name =
      data
      |> Enum.map(&(&1["name"]))

    url =
      data
      |> get_urls

    address =
      data
      |> Enum.map(&(&1["location"]["street"]))

    city =
      data
      |> Enum.map(&(&1["location"]["city"]))

    state =
      data
      |> Enum.map(&(&1["location"]["state"]))

    zip =
      data
      |> Enum.map(&(&1["location"]["zip"]))

    phone =
      data
      |> Enum.map(&(&1["phone"]))

    add_to_result List.zip([name, address, city, state, zip, phone, url])
  end

  def add_to_result([]), do: []
  def add_to_result([{name, address, city, state, zip, phone, url} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip, phone: phone, url: url} | add_to_result(tail)]
  end

  def remove_nil_entries([]), do: []
  def remove_nil_entries([head|tail]) do
    if head do
      [head|remove_nil_entries(tail)]
    else
      remove_nil_entries(tail)
    end
  end

  # Enum.map(&(if &1["category"] == "Local business", do: &1))

  def get_token, do: Helpers.fetch_html("https://graph.facebook.com/oauth/access_token?client_id=1630177573975468&client_secret=#{get_key}&grant_type=client_credentials")
  defp get_key, do: Application.get_env(:locorum, :facebook)[:key]

  def get_urls([]), do: []
  def get_urls([head|tail]) do
    url = "https://www.facebook.com/pages/#{Helpers.convert_to_utf(head["name"], "-")}/#{head["id"]}"
    [url | get_urls(tail)]
  end
end
