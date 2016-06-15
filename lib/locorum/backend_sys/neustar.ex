defmodule Locorum.BackendSys.Neustar do
  alias Locorum.BackendSys.Helpers
  # alias Locorum.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_html
    |> parse_data
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

    biz =
      focus
      |> Floki.find("h4")
      |> Floki.text

    address =
      focus
      |> Floki.find("span[itemprop=streetAddress]")
      |> Floki.text
      |> title_case

    city =
      focus
      |> Floki.find("span[itemprop=addressLocality]")
      |> Floki.text
      |> title_case

    state =
      focus
      |> Floki.find("span[itemprop=addressRegion]")
      |> Floki.text

    zip =
      focus
      |> Floki.find("span[itemprop=postalCode]")
      |> Floki.text
      |> String.split("-")
      |> List.first

    phone =
      focus
      |> Floki.find("div[itemprop=telephone]")
      |> Floki.text

    [{_, [_, {_, url}], _}] =
      focus
      |> Floki.find("a[href]")

    url = "https://www.neustarlocaleze.biz#{url}"

  end

  def pull_address_data(set) do
  end

  def title_case(string) do
    string
    |> String.split(" ")
    |> Enum.map(&("#{String.capitalize(&1)} "))
    |> List.to_string
    |> String.strip
  end
end
