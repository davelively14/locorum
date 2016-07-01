defmodule Locorum.SearchControllerTest do
  use Locorum.ConnCase
  alias Locorum.Search
  alias Locorum.TestHelpers

  @need_user_attrs %{biz: "A Biz Name", zip: "34593", city: "Atlanta", state: "GA", address1: "369 James St SE", phone: "4042607121"}
  @invalid_attrs %{zip: "1234"}

  setup %{conn: conn} = config do
    if _username = config[:logged_in] do
      user = TestHelpers.insert_user(username: "searcher")
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authenticiation for all search actions", %{conn: conn} do
    Enum.each([
      get(conn, search_path(conn, :new)),
      get(conn, search_path(conn, :edit, "1")),
      put(conn, search_path(conn, :update, "1", %{})),
      post(conn, search_path(conn, :create, %{})),
      delete(conn, search_path(conn, :delete, "1"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
  # 
  # @tag :logged_in
  # test "creates search and redirects to project page", %{conn: conn, user: user} do
  #   attrs =
  #     @need_user_attrs
  #     |> Map.put(:user_id, user.id)
  #     |> Map.put(:project_id, 1)
  #   conn = post conn, search_path(conn, :create), search: attrs
  #   search = Repo.get_by!(Search, attrs)
  #   assert redirected_to(conn) == project_path(conn, :show, search.project_id)
  # end
  #
  # @tag :logged_in
  # test "deletes search and redirects to index page", %{conn: conn} do
  #   search = Repo.insert! %Search{}
  #   conn = delete conn, search_path(conn, :delete, search)
  #   assert redirected_to(conn) == search_path(conn, :index)
  #   refute Repo.get(Search, search.id)
  # end
  #
  # @tag :logged_in
  # test "does not create a new search with invalid attributes", %{conn: conn} do
  #   conn = post conn, search_path(conn, :create), search: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New Search"
  #   refute Repo.get_by(Search, @invalid_attrs)
  # end
end
