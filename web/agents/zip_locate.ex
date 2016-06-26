defmodule Locorum.ZipLocate do
  @doc """
  This agent will maintain state that contains a list that returns a lat/long tuple for a given postal code (zip).
  """

  def start_link do
    Agent.start_link(fn -> get_data end)
  end

  def get(agent, zip) do
    Agent.get(agent, &Map.get(&1, zip))
  end

  def put(agent, zip, {lat, long}) do
    Agent.update(agent, &Map.put(&1, zip, {lat, long}))
  end

  def get_data do
    {:ok, result} = File.read("/Users/DavesMac/Projects/PEEPs/locorum/priv/static/zip/zip.csv")

    result
    |> String.split("\n")
    |> Enum.drop(1)
    |> build_map
  end

  defp build_map([]), do: nil
  defp build_map(list), do: build_map(list, %{})
  defp build_map([], map), do: map
  defp build_map([head|tail], map) do
    coords = head |> String.split(",")
    map = map |> Map.put(Enum.at(coords, 0), {Enum.at(coords, 1), Enum.at(coords, 2)})
    build_map(tail, map)
  end
end
