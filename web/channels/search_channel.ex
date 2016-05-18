defmodule Locorum.SearchChannel do
  alias Locorum.Search
  alias Locorum.Repo
  alias Locorum.Result
  use Locorum.Web, :channel
  import Ecto.Query, only: [from: 2]

  @max_results 3

  def join("searches:" <> search_id, _params, socket) do

    {:ok, assign(socket, :search_id, search_id)}
  end

  def handle_in("run_search", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }

    search = Repo.get!(Search, socket.assigns.search_id)
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)
    {:reply, :ok, socket}
  end

  def handle_in("result", params, socket) do
    result_params = params
    changeset = Result.changeset(%Result{}, result_params)
    {:reply, changeset, socket}
  end

  defp check_max(search_id) do
    results =
      from r in Result, where: r.search_id = search_id
      |> Repo.all
      |> Enum.sort(&(Ecto.DateTime.compare(&1.inserted_at, &2.inserted_at)))
      |> trim_to_max
  end

  defp trim_to_max([]), do: []
  defp trim_to_max(results) when length(results) < @max_results, do: results
  defp trim_to_max([head|tail]) do
    Repo.delete head
    trim_to_max tail
  end
end
