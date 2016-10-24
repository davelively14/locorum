defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase
  alias Locorum.{TestHelpers, ProjectChannelSupervisor, ProjectChannelServer}

  #########
  # Setup #
  #########

  @empty_project_id 1
  @not_started_project_id 111

  setup %{conn: conn} = config do
    if config[:full_project] do
      project = TestHelpers.insert_full_project
      {:ok, conn: conn, project_id: project.id}
    else
      :ok
    end
  end

  #########
  # Tests #
  #########

  # Tags used:
  # :project_server -> Every test related to the server
  # :full_project -> Setup config with a full project in the Test Repo

  @tag :project_server
  test "get_state on project with no results returns empty state" do
    ProjectChannelSupervisor.start_link(@empty_project_id)
    assert ProjectChannelServer.get_state(@empty_project_id) == %{all_collections: [], newest_collections: [], collection_list: [], backends: [], searches: []}
  end

  @tag :full_project
  @tag :project_server
  test "get_state on full project returns correct results", %{project_id: project_id} do
    ProjectChannelSupervisor.start_link(project_id)
    state = ProjectChannelServer.get_state(project_id)

    assert state.backends |> List.first |> Map.fetch(:backend) == {:ok, "Google"}
    assert state.all_collections == :all_collections
    assert length(state.collection_list) == 2
    assert length(state.newest_collections) == 2
    assert length(state.searches) == 2
  end

  @tag :project_server
  test "get_dep_state on project with no results returns empty state in deprecated format" do
    ProjectChannelSupervisor.start_link(@empty_project_id)
    assert ProjectChannelServer.get_dep_state(@empty_project_id) == %{collections: [], collection_list: [], backends: []}
  end

  @tag :full_project
  @tag :project_server
  test "get_dep_state on full project returns correct results", %{project_id: project_id} do
    ProjectChannelSupervisor.start_link(project_id)
    state = ProjectChannelServer.get_dep_state(project_id)

    assert state.backends |> List.first |> Map.fetch(:backend) == {:ok, "Google"}
    assert state.collections |> List.first |> Map.fetch(:id) == state.collection_list |> List.first |> Map.fetch(:result_collection_id)
  end

  @tag :project_server
  test "is_online returns accurate online status for server" do
    ProjectChannelSupervisor.start_link(@empty_project_id)
    assert ProjectChannelServer.is_online(@empty_project_id)
    refute ProjectChannelServer.is_online(@not_started_project_id)
  end

  @tag :full_project
  @tag :project_server
  test "get_searches returns all searches for a project", %{project_id: project_id} do
    ProjectChannelSupervisor.start_link(project_id)
    assert length(ProjectChannelServer.get_searches(project_id)) == 2
  end
end
