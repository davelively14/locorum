defmodule Locorum.BackendSys.Bing do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

  @fixed_url "https://www.bingplaces.com/DashBoard/Home"

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    get_url(query) # url
    |> Helpers.fetch_html # body
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

    "http://www.bing.com/search?q=#{biz}+#{city}+#{state}"
  end

  def parse_data(body) do
    focus =
      Floki.find(body, "div.ent_cnt")
      |> Floki.raw_html

    biz =
      cond do
        length(Floki.find(focus, ".b_vPanel")) > 0 ->
          body
          |> Floki.find(".b_entityTitle")
          |> Floki.text
          |> List.wrap
        true ->
          focus
          |> Floki.find("h2")
          |> Enum.map(&elem(&1, 2))
          |> Enum.map(&Floki.text(&1))
      end

    location_data =
      focus
      |> Floki.find("span.b_address")
      |> Enum.map(fn {_, _, element} -> List.first(element) end)
      |> Enum.map(&String.split(&1, ", "))
      |> Enum.map(&Enum.reverse/1)

    {state, zip} =
      location_data
      |> Enum.map(&List.first/1)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(&List.to_tuple/1)
      |> Enum.unzip

    city =
      location_data
      |> Enum.map(&Enum.drop(&1, 1))
      |> Enum.map(&List.first/1)

    address =
      location_data
      |> Enum.map(&Enum.drop(&1, 2))
      |> Enum.map(&join_address/1)

    phone =
      focus
      |> Floki.find(".b_factrow")
      |> Floki.text
      |> String.split(~r/\(/)
      |> Enum.drop(1)
      |> Enum.map(&String.slice(&1, 0, 13))
      |> Enum.map(&String.replace(&1, "\) ", ""))
      |> Enum.map( &String.replace(&1, "-", ""))

    List.zip([biz, address, city, state, zip, phone])

  end

  def join_address([]), do: nil
  def join_address([head|tail]), do: join_address(tail, head)
  defp join_address([], string), do: string
  defp join_address([head|tail], string), do: join_address(tail, "#{string}, #{head}")
end
