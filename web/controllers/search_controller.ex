defmodule Locorum.SearchController do
  use Locorum.Web, :controller
  alias Locorum.Search

  def new(conn, _params) do
    changeset = Search.changeset(%Search{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"search" => search_params}) do
    changeset = Search.changeset(%Search{}, search_params)
    case Repo.insert(changeset) do
      {:ok, search} ->
        conn
        |> put_flash(:info, "search ran!")
        |> redirect(to: search_path(conn, :show, search))
    end
  end

  def show(conn, %{"id" => id}) do
    search = Repo.get(Locorum.Search, id)
    render conn, "show.html", search: search
  end

  def index(conn, _params) do
    searches = Repo.all(Locorum.Search)
    render conn, "index.html", searches: searches
  end

  def delete(conn, %{"id" => id}) do
    search = Repo.get(Locorum.Search, id)
    Repo.delete search
    redirect(conn, to: search_path(conn, :index))
  end
end
