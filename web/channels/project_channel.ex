defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel
  alias Locorum.{ProjectChannelServer, ProjectChannelSupervisor}

  def join("projects:" <> project_id, _params, socket) do
    if !ProjectChannelServer.is_online(project_id) do
      ProjectChannelSupervisor.start_link(project_id)
    end

    {:ok, ProjectChannelServer.get_dep_state(project_id), assign(socket, :project_id, project_id)}
  end

  def handle_in("run_search", _params, socket) do
    searches = ProjectChannelServer.get_searches(socket.assigns.project_id)
    {:ok, pid} = Locorum.BackendSysSupervisor.start_link(searches, socket)
    Process.monitor(pid)
    {:reply, :ok, socket}
  end

  def handle_in("run_single_search", params, socket) do
    search = ProjectChannelServer.get_single_search(socket.assigns.project_id, params["search_id"])
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)

    {:reply, :ok, socket}
  end

  def handle_in("fetch_collection", params, socket) do
    resp = %{collection: ProjectChannelServer.get_collection(socket.assigns.project_id, params["collection_id"])}
    broadcast!(socket, "render_collection", resp)

    {:noreply, socket}
  end
end
