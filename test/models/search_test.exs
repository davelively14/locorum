defmodule Locorum.SearchTest do
  use Locorum.ConnCase
  alias Locorum.Search

  # TODO login before testing all of these
  @valid_attrs %{biz: "A Biz Name", zip: "34593", city: "Atlanta", state: "GA", address1: "369 James St SE", phone: "4042607121"}
  @invalid_attrs %{zip: "1234"}

  test "requires user authenticiation for all search actions", %{conn: conn} do
    Enum.each([
      get(conn, search_path(conn, :new)),
      get(conn, search_path(conn, :index)),
      get(conn, search_path(conn, :show, "1")),
      get(conn, search_path(conn, :edit, "1")),
      put(conn, search_path(conn, :update, "1", %{})),
      post(conn, search_path(conn, :create, %{})),
      delete(conn, search_path(conn, :delete, "1"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  test "creates search and redirects to results page", %{conn: conn} do
    conn = post conn, search_path(conn, :create), search: @valid_attrs
    search = Repo.get_by!(Search, @valid_attrs)
    assert redirected_to(conn) == results_path(conn, :show, search)
  end

  test "deletes search and redirects to index page", %{conn: conn} do
    search = Repo.insert! %Search{}
    conn = delete conn, search_path(conn, :delete, search)
    assert redirected_to(conn) == search_path(conn, :index)
    refute Repo.get(Search, search.id)
  end

  test "does not create a new search with invalid attributes", %{conn: conn} do
    conn = post conn, search_path(conn, :create), search: @invalid_attrs
    assert html_response(conn, 200) =~ "New Search"
    refute Repo.get_by(Search, @invalid_attrs)
  end
end
