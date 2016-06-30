defmodule Locorum.ProjectControllerTest do
  use Locorum.ConnCase
  alias Locorum.Search
  alias Locorum.Project
  alias Locorum.TestHelpers

  @valid_attrs %{name: "New Project"}
  @invalid_attrs %{name: nil, user_id: nil}

  setup %{conn: conn} = config do
    if config[:logged_in] do
      user = TestHelpers.insert_user
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "require authorization to access any project action", %{conn: conn} do
    Enum.each([
      get(conn, project_path(conn, :new)),
      get(conn, project_path(conn, :index)),
      get(conn, project_path(conn, :show, "1")),
      get(conn, project_path(conn, :edit, "1")),
      put(conn, project_path(conn, :update, "1", %{})),
      post(conn, project_path(conn, :create, %{})),
      delete(conn, project_path(conn, :delete, "1"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag :logged_in
  test "create new project and redirects to show page", %{conn: conn, user: user} do
    attrs = Map.put(@valid_attrs, :user_id, user.id)
    conn = post conn, project_path(conn, :create), project: attrs
    project = Repo.get_by!(Project, attrs)
    assert redirected_to(conn) == project_path(conn, :show, project)
  end

  @tag :logged_in
  test "deletes project and redirects to index page", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = delete conn, project_path(conn, :delete, project)
    assert redirected_to(conn) == project_path(conn, :index)
    refute Repo.get(Project, project.id)
  end

  @tag :logged_in
  test "does not create a new project with invalid attributes", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: %{name: nil}
    assert html_response(conn, 200) =~ "New Project"
    refute Repo.get_by!(Project, %{name: "reals"})
  end
end
