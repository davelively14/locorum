defmodule Locorum.CSVController do
  use Locorum.Web, :controller

  def create(conn, %{"csv" => csv}) do
    case File.read!(csv) do
      {:ok, result} ->
        result =
          result
          |> String.split("\n")
          |> Locorum.BackendSys.Helpers.pop_first(1)
          |> split_results
        # TODO escaping quotations ruins everthing. Hardcode acceptance.
      _ ->
        {:error, "Invalid file type"}
    end
  end

  def split_results([]), do: []
  def split_results([head|tail]), do: [String.split(head, ",")|split_results(tail)]

  def join_results(keys, values) do
    join_results(keys, values, %{})
  end
  def join_results([], [], acc), do: acc
  def join_results([], _, acc), do: {:error, "Values longer than keys"}
  def join_results(_, [], acc), do: {:error, "Keys longer than values"}
  def join_results([keys_head|keys_tail], [values_head|values_tail], acc) do
    join_results(keys_tail, values_tail, Map.put(acc, keys_head, values_head))
  end

  def get_size(list), do: get_size(list, 0)
  def get_size([], acc), do: acc
  def get_size([head|tail], acc), do: get_size(tail, acc + 1)

  # def add_to_search([]), do: []
  # def add_to_search([head|tail]) do
  #
  # end
end
