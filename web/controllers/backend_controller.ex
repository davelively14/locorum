defmodule Locorum.BackendController do
  use Locorum.Web, :controller
  alias Locorum.Backend

  def new(conn, _params) do
    changeset = Backend.changeset(%Backend{})
    render conn, "new.html", changeset: changeset, cancel_action: get_refer(conn)
  end

  def create(conn, %{"backend" => backend_params}) do
    changeset = Backend.changeset(%Backend{}, backend_params)
    case Repo.insert(changeset) do
      {:ok, backend} ->
        conn
        |> put_flash(:info, "Created the #{backend.name_str} backend")
        |> redirect(to: backend_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset, cancel_action: backend_path(conn, :index)
    end
  end

  def index(conn, _params) do
    backends = Repo.all(Backend)
    render conn, "index.html", backends: backends
  end

  def delete(conn, %{"id" => id}) do
    backend = Repo.get(Backend, id)
    Repo.delete backend
    redirect conn, external: get_refer(conn)
  end

  # TODO DRY refactor
  defp get_refer(conn) do
    {_, referer} = List.keyfind(conn.req_headers, "referer", 0) || {0, backend_path(conn, :index)}
    referer
  end
end
