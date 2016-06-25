defmodule Locorum.BackendSys.Neustar do
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
    city =
      query.city
      |> Helpers.convert_to_utf("+")

    state = query.state

    biz =
      query.biz
      |> Helpers.convert_to_utf("+")

    "https://www.neustarlocaleze.biz/directory/us?Name=#{biz}&Location=#{city}+#{state}"
  end

  def parse_data(body) do
    focus = body |> Floki.find(".list-group")

    name =
      focus
      |> Floki.find("h4")
      |> Enum.map(&Floki.text/1)

    address =
      focus
      |> Floki.find("span[itemprop=streetAddress]")
      |> Enum.map(&(Floki.text(&1) |> title_case))

    city =
      focus
      |> Floki.find("span[itemprop=addressLocality]")
      |> Enum.map(&(Floki.text(&1) |> title_case))

    state =
      focus
      |> Floki.find("span[itemprop=addressRegion]")
      |> Enum.map(&Floki.text/1)

    zip =
      focus
      |> Floki.find("span[itemprop=postalCode]")
      |> Enum.map(&(Floki.text(&1) |> String.split("-") |> List.first))

    phone =
      focus
      |> Floki.find("div[itemprop=telephone]")
      |> Enum.map(&Floki.text/1)

    url =
      focus
      |> Floki.find("h4 a[href]")
      |> Enum.map(&pull_url/1)

    add_to_result List.zip([name, address, city, state, zip, phone, url])
  end

  def pull_url(element) do
    {_, [_, {_, url}], _} = element
    "https://www.neustarlocaleze.biz#{url}"
  end

  def title_case(string) do
    string
    |> String.split(" ")
    |> Enum.map(&("#{String.capitalize(&1)} "))
    |> List.to_string
    |> String.strip
  end

  def add_to_result([]), do: []
  def add_to_result([{name, address, city, state, zip, phone, url} | tail]) do
    [%Result{biz: name, address: address, city: city, state: state, zip: zip, phone: phone, url: url} | add_to_result(tail)]
  end
end
