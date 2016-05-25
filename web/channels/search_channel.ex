defmodule Locorum.SearchChannel do
  alias Locorum.Search
  alias Locorum.Repo
  alias Locorum.ResultCollection
  use Locorum.Web, :channel

  def join("searches:" <> search_id, _params, socket) do
    search_id = String.to_integer(search_id)
    collections = Repo.all from c in ResultCollection,
                           where: c.search_id == ^search_id,
                           order_by: [desc: c.inserted_at],
                           preload: [:results]
    first_collection = List.first(collections)
    results = first_collection.results
    resp = %{results: Phoenix.View.render_many(results, Locorum.ResultsView, "result.json")}
    {:ok, resp, assign(socket, :search_id, search_id)}
  end

  def handle_in("run_search", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }

    search = Repo.get!(Search, socket.assigns.search_id)
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)
    {:reply, :ok, socket}
  end

  # def handle_out("result", payload, socket) do
  #   payload["search_id"]
  #   |> check_max
  #
  #   changeset = Result.changeset(%Result{}, payload)
  #   case Repo.insert(changeset) do
  #     {:ok, _result} ->
  #       push socket, "result", payload
  #       {:noreply, socket}
  #     {:error, changeset} ->
  #       push socket, "error", %{
  #         error: changeset.errors
  #       }
  #   end
  # end
end
