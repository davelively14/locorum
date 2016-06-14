defmodule Locorum.BackendSys.Bing do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

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

    if length(Floki.find(focus, ".b_vPanel") > 0) do
      title =
        body
        |> Floki.find(".b_entityTitle")
        |> Floki.text
        |> List.wrap
    else
      title =
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

    phone =
      focus
      |> Floki.find(".b_factrow")
      |> Floki.text
      |> String.split(~r/\(/)
      |> Helpers.pop_first(1)
      |> Enum.map(&String.slice(&1, 0, 13))
      |> Enum.map(&String.replace(&1, "\) ", ""))
      |> Enum.map( &String.replace(&1, "-", ""))

    url = "https://www.bingplaces.com/DashBoard/Home"


  end

  defp parse_address([]), do: []
  defp parse_address(list), do: parse_address(list, [])
  defp parse_address([], acc), do: acc
  defp parse_address([head|tail], acc) do

  end

  # defp add_to_results(list) do
  #   temp_list = List.reverse(list)
  #
  #   state_zip =
  #     temp_list
  #     |> Enum.at(0)
  #     |> String.split(" ")
  #
  #   state = Enum.at(state_zip, 0)
  #   zip = Enum.at(state_zip, 1)
  #   city = Enum.at(temp_list, 1)
  #   address =
  #     temp_list
  #     |> pop_tops(2)
  #     |> rebuild_address
  #
  #
  # end
  #
  # def pop_tops([head|tail], current) when current > 0, do: pop_tops(tail, current - 1)
  # def pop_tops(remaining, current), do: remaining
  #
  # def rebuild_address([]), do: ""
  # def rebuild_address([head|tail]), do: rebuild_address(tail, head)
  # def rebuild_address([], result), do: result
  # def rebuild_address([head|tail], result), do: rebuild_address(tail, "#{result}, #{head}")
end
