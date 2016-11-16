defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel
  alias Locorum.{ProjectChannelServer, ProjectChannelSupervisor}

  def join("projects:" <> project_id, _params, socket) do

    # Starts the ProjectChannelSupervisor for the given project_id if it's not
    # already started.
    unless ProjectChannelServer.is_online(project_id) do
      ProjectChannelSupervisor.start_link(project_id)
    end

    {:ok, ProjectChannelServer.get_dep_state(project_id), assign(socket, :project_id, project_id)}
  end

  def handle_in("run_search", _params, socket) do
    ProjectChannelServer.fetch_new_results(socket)
    {:reply, :ok, socket}
  end

  def handle_in("run_single_search", params, socket) do
    ProjectChannelServer.fetch_new_results(socket, params["search_id"])
    {:reply, :ok, socket}
  end

  def handle_in("fetch_collection", params, socket) do
    ProjectChannelServer.fetch_collection(socket, params["collection_id"])
    {:noreply, socket}
  end
end
