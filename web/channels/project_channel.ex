defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel
  alias Locorum.ProjectChannelServer

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
    search = ProjectChannelServer.get_single_search(socket.assigns.project_id, params["search_id"])
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)

    {:reply, :ok, socket}
  end

  def handle_in("fetch_collection", params, socket) do
    resp = %{collection: ProjectChannelServer.get_collection(socket.assigns.project_id, params["collection_id"])}
    IO.inspect resp
    broadcast!(socket, "render_collection", resp)

    {:noreply, socket}
  end
end
