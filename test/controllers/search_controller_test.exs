defmodule Locorum.SearchControllerTest do
  use Locorum.ConnCase
  alias Locorum.Search

  @valid_attrs %{biz: "A Biz Name", zip: "34593", city: "Atlanta", state: "GA"}
  @invalid_attrs %{zip: "1234"}

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
