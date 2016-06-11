defmodule Locorum.BackendSys.Bing do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, _owner, _limit) do
    get_url(query)
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

    "http://www.bing.com/search?q=#{biz}+#{city}+#{state}"
  end

  def parse_data(body) do
    results =
      Floki.find(body, "div.ent_cnt")
      |> Floki.raw_html
      |> Floki.find("span.b_address")
      |> parse_item
      # |> add_to_results

    results
  end

  defp parse_item([]), do: []
  defp parse_item([{_, _,[item]} | tail]), do: [String.strip(item) | parse_item(tail)]
  defp parse_item([item | tail]), do: [String.strip(item) | parse_item(tail)]

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
