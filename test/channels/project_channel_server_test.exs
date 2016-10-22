defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase

  @empty_project_id 1

  @tag :project_server
  test "get_state on project with no results returns empty state", %{conn: _conn} do
    Locorum.ProjectChannelSupervisor.start_link(@empty_project_id)
    assert Locorum.ProjectChannelServer.get_state(@empty_project_id) == %{all_collections: [], newest_collections: [], collection_list: [], backends: []}
  end

  @tag :project_server
  test "get_dep_state on project with no results returns empty state in deprecated format" do
    Locorum.ProjectChannelSupervisor.start_link(@empty_project_id)
    assert Locorum.ProjectChannelServer.get_dep_state(@empty_project_id) == %{collections: [], collection_list: [], backends: []}
  end
end
