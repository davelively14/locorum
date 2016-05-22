defmodule Locorum.BackendController do
  use Locorum.Web, :controller
  alias Locorum.Backend

  def new(conn, _params) do
    changeset = Backend.changeset(%Backend{})
    render conn, "new.html", changeset: changeset, cancel_action: get_refer(conn)
  end

  def create(conn, params) do
    nil
  end

  def show(conn, %{"id" => backend_id}) do
    nil
  end

  defp get_refer(conn) do
    {_, referer} = List.keyfind(conn.req_headers, "referer", 0) || {0, page_path(conn, :index)}
    referer
  end
end
