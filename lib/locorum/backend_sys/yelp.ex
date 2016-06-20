defmodule Locorum.BackendSys.Yelp do
  alias Locorum.BackendSys.Helpers
  # alias Locorum.BackendSys.Result

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
    address = query.address1 |> Helpers.convert_to_utf("+")
    name = query.biz |> Helpers.convert_to_utf("+")

    "https://www.yelp.com/search?find_desc=#{name}&find_loc=#{address}"
  end

  def parse_data(body) do
    focus = body |> Floki.find(".regular-search-result")

    name =
      focus
      |> Enum.map(&(Floki.find(&1, ".biz-name") |> List.first |> elem(2) |> List.first |> elem(2) |> get_names))

    address_group =
      focus
      |> Floki.find("address")
      |> Enum.map(&(Floki.text(&1) |> String.strip |> String.split("\n")))

    phone =
      focus
      |> Floki.find(".biz-phone")
      |> Enum.map(&(Floki.text(&1) |> String.strip))

    url =
      focus
      |> Enum.map(&(Floki.find(&1, ".biz-name") |> Floki.attribute("href") |> List.to_string |> Yelp.make_url))
  end

  def get_names(element) do
    element
    |> strip_format
    |> list_to_spaced_str
  end

  def strip_format([]), do: []
  def strip_format([head|tail]) when is_tuple(head), do: [Floki.text(head) | strip_format(tail)]
  def strip_format([head|tail]), do: [String.strip(head) | strip_format(tail)]

  def list_to_spaced_str([]), do: nil
  def list_to_spaced_str([head|tail]), do: list_to_spaced_str(tail, "#{head}")
  def list_to_spaced_str([], str), do: str
  def list_to_spaced_str([head|tail], str), do: list_to_spaced_str(tail, "#{str} #{head}")

  def make_url(str), do: "https://www.yelp.com#{str}"
end
