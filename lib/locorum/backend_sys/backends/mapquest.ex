defmodule Locorum.BackendSys.Mapquest do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_html
    |> parse_data
    |> Helpers.display_results(__MODULE__, owner, query, get_url(query))
  end

  def get_url(query) do
    name = query.biz |> Helpers.convert_to_utf("%20")
    state = query.state
    city = query.city |> Helpers.convert_to_utf("%20")

    "https://www.mapquest.com/search/results?page=0&query=#{name}%20#{city}%20#{state}"
  end

  def parse_data(body) do
    focus =
      body
      |> Floki.find("script[id=SearchResults]")
      |> List.first
      |> elem(2)
      |> List.first
      |> Poison.decode!
      |> Map.fetch!("results")
      |> Enum.map(&(if !&1["@adparameters"], do: &1))
      |> strip_nil

    name = focus |> Enum.map(&(&1["name"]))

    address = focus |> Enum.map(&(&1["address"]["address1"]))

    city = focus |> Enum.map(&(&1["address"]["locality"]))

    state = focus |> Enum.map(&(&1["address"]["region"]))

    zip = focus |> Enum.map(&(&1["address"]["postalCode"]))

    url = focus |> Enum.map(&("https://www.mapquest.com#{&1["slug"]}"))

    add_to_result List.zip([name, address, city, state, zip, url])
  end

  def add_to_result([]), do: []
  def add_to_result([{name, address, city, state, zip, url} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip, url: url, phone: "N/A"} | add_to_result(tail)]
  end

  def strip_nil([]), do: []
  def strip_nil([head|tail]) do
    case head do
      nil ->
        strip_nil(tail)
      _ ->
        [head | strip_nil(tail)]
    end
  end
end
