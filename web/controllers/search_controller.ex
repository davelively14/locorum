defmodule Locorum.SearchController do
  use Locorum.Web, :controller
  alias Locorum.Search

  plug :scrub_params, "search" when action in [:create]

  def new(conn, _params) do
    changeset = Search.changeset(%Search{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"search" => search_params}) do
    changeset = Search.changeset(%Search{}, search_params)
    case Repo.insert(changeset) do
      {:ok, search} ->
        conn
        |> put_flash(:info, "Search created")
        |> redirect(to: results_path(conn, :show, search))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    changeset = Search.changeset(search)
    render conn, "edit.html", search: search, changeset: changeset
  end

  def update(conn, %{"id" => id, "search" => search_params}) do
    search = Repo.get(Search, id)
    changeset = Search.changeset(search, search_params)

    case Repo.update(changeset) do
      {:ok, search} ->
        conn
        |> put_flash(:info, "Search updated")
        |> redirect(to: search_path(conn, :show, search))
      {:error, changeset} ->
        render(conn, "edit.html", search: search, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    render conn, "show.html", search: search
  end

  def index(conn, _params) do
    searches = Repo.all(Search)
    render conn, "index.html", searches: searches
  end

  def delete(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    Repo.delete search
    redirect(conn, to: search_path(conn, :index))
  end
end
