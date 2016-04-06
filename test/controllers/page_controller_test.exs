defmodule Locorum.PageControllerTest do
  use Locorum.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Locorum!"
  end
end
