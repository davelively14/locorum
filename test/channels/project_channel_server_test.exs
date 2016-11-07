defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase
  use Locorum.ChannelCase
  alias Locorum.{TestHelpers, ProjectChannelSupervisor, ProjectChannelServer, ProjectChannel}

  #########
  # Setup #
  #########

  @empty_project_id 1
  @not_started_project_id 111

  setup %{conn: conn} = config do
    cond do
      config[:full_project] ->
        project = TestHelpers.insert_full_project
        {:ok, conn: conn, project_id: project.id}
      config[:full_project_user] ->
        project = TestHelpers.insert_full_project
        user = TestHelpers.insert_user
        conn = assign(conn, :current_user, user)
        {:ok, conn: conn, project_id: project.id}
      config[:full_project_join] ->
        project = TestHelpers.insert_full_project
        user = TestHelpers.insert_user
        {:ok, _, socket} =
          socket("", %{})
          |> subscribe_and_join(ProjectChannel, "projects:#{project.id}")
        socket = Phoenix.Socket.assign(socket, :user_id, user.id)
        conn =
          assign(conn, :current_user, user)
          |> assign(:socket, socket)
        {:ok, conn: conn, project_id: project.id, socket: socket}
      true ->
        :ok
    end
  end

  #########
  # Tests #
  #########

  # Tags used:
  # :project_server -> Every test related to the server
  # :full_project -> Setup config with a full project in the Test Repo
  # :full_project_join -> Same as :full_project, plus joins a ProjectChannel

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

  @tag :full_project
  @tag :project_server
  test "get_single_search returns a single search", %{project_id: project_id} do
    ProjectChannelSupervisor.start_link(project_id)
    search_to_check = ProjectChannelServer.get_searches(project_id) |> List.first
    assert ProjectChannelServer.get_single_search(project_id, search_to_check.id) == search_to_check
    assert ProjectChannelServer.get_single_search(project_id, Integer.to_string(search_to_check.id)) == search_to_check
  end

  @tag :full_project
  @tag :project_server
  test "get_updated_results/1 returns the newest collections", %{project_id: project_id} do
    ProjectChannelSupervisor.start_link(project_id)
    collections_to_fetch = ProjectChannelServer.get_state(project_id) |> Map.get(:newest_collections)
    assert ProjectChannelServer.get_updated_results(project_id) == collections_to_fetch
  end

  @tag :full_project
  @tag :project_server
  test "get_updated_result/2 returns most recent collection for a given search", %{project_id: project_id} do
    ProjectChannelSupervisor.start_link(project_id)
    results_to_check = ProjectChannelServer.get_updated_results(project_id) |> List.first
    assert ProjectChannelServer.get_updated_result(project_id, results_to_check.search_id) == results_to_check
    assert ProjectChannelServer.get_updated_result(project_id, Integer.to_string(results_to_check.search_id)) == results_to_check
  end

  @tag :full_project_join
  @tag :project_server
  test "fetch_collection returns the correct collection", %{socket: socket} do
    project_id = String.to_integer(socket.assigns.project_id)
    ProjectChannelSupervisor.start_link(project_id)
    collection = ProjectChannelServer.get_updated_results(project_id) |> List.first
    ProjectChannelServer.fetch_collection(socket, collection.id)
    assert_broadcast("render_collection", %{collection: ^collection}, 1_000)
    leave socket
  end

  # The best I can do for now is just confirm that it receives something back.
  # Not exactly sure how to test for content that is dynamically provided.
  # Probably have to setup a dummy backend.
  @tag :full_project_join
  @tag :project_server
  test "fetch_new_results receives new results", %{project_id: project_id, conn: conn} do
    ProjectChannelSupervisor.start_link(project_id)
    user_id = conn.assigns.current_user.id
    socket = conn.assigns.socket

    ProjectChannelServer.fetch_new_results(project_id, user_id, socket)
    assert_broadcast("new_results", _, 5_000)
    leave socket
  end
end
