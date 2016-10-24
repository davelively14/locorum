defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel
  alias Locorum.ProjectChannelServer
  alias Locorum.ResultCollection
  alias Locorum.Result

  def join("projects:" <> project_id, _params, socket) do
    if !Locorum.ProjectChannelServer.is_online(project_id) do
      Locorum.ProjectChannelSupervisor.start_link(project_id)
    end

    {:ok, ProjectChannelServer.get_dep_state(project_id), assign(socket, :project_id, project_id)}
  end

  # TODO remove this function...doesn't seem to be used
  def add_search_id(collection), do: add_search_id(collection.results, collection.search_id)
  defp add_search_id([], _search_id), do: []
  defp add_search_id([head|tail], search_id), do: [Map.put_new(head, :search_id, search_id) | add_search_id(tail, search_id)]

  def handle_in("run_search", _params, socket) do
    searches = ProjectChannelServer.get_searches(socket.assigns.project_id)

    for search <- searches, do: Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)
    {:reply, :ok, socket}
  end

  def handle_in("run_single_search", params, socket) do
    # search = Repo.get!(Locorum.Search, params["search_id"])
    search = ProjectChannelServer.get_single_search(socket.assigns.project_id, params["search_id"])
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)

    {:reply, :ok, socket}
  end

  def handle_in("fetch_collection", params, socket) do
    preload_results = from r in Result, order_by: [desc: r.rating]
    collection = Repo.one from c in ResultCollection,
                          where: c.id == ^params["collection_id"],
                          preload: [results: ^preload_results, results: :backend]

    resp = %{collection: Phoenix.View.render(Locorum.ResultCollectionView, "result_collection.json", result_collection: collection)}

    broadcast!(socket, "render_collection", resp)

    {:noreply, socket}
  end
end
