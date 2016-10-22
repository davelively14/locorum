defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase

  @empty_project_id 1
  @down_project_id 111

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

  @tag :project_server
  test "is_online returns accurate online status for server" do
    Locorum.ProjectChannelSupervisor.start_link(@empty_project_id)
    assert Locorum.ProjectChannelServer.is_online(@empty_project_id)
    refute Locorum.ProjectChannelServer.is_online(@down_project_id)
  end
end
