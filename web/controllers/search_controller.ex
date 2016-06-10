defmodule Locorum.SearchController do
  use Locorum.Web, :controller
  alias Locorum.Search
  require Logger

  plug :scrub_params, "search" when action in [:create, :update]

  def new(conn, _params) do
    user = conn.assigns.current_user
    changeset = Search.changeset(%Search{user_id: user.id})
    render conn, "new.html", changeset: changeset, cancel_action: get_refer(conn)
  end

  def create(conn, %{"search" => search_params}) do
    if search_params["address2"] && String.length(search_params["address2"]) > 0 do
      search_params =
        Map.update!(search_params, "address1", &(&1 <> ", #{search_params["address2"]}"))
        |> Map.delete("address2")
    end
    changeset = Search.changeset(%Search{}, search_params)
    case Repo.insert(changeset) do
      {:ok, search} ->
        case search.project_id do
          nil ->
            conn
            |> put_flash(:info, "Search created")
            |> redirect(to: results_path(conn, :show, search))
          id ->
            conn
            |> put_flash(:info, "Search created")
            |> redirect(to: project_path(conn, :show, id))
        end
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset, cancel_action: get_refer(conn)
    end
  end

  def edit(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    changeset = Search.changeset(search)
    render conn, "edit.html", search: search, changeset: changeset, cancel_action: get_refer(conn)
  end

  def update(conn, %{"id" => id, "search" => search_params}) do
    if search_params["address2"] && String.length(search_params["address2"]) > 0 do
      search_params =
        Map.update!(search_params, "address1", &(&1 <> ", #{search_params["address2"]}"))
        |> Map.delete("address2")
    end
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
    search = Map.put(search, :phone, phonify(search.phone))
    render conn, "show.html", search: search, back_action: get_refer(conn)
  end

  def index(conn, _params) do
    searches = Repo.all(Search)
    render conn, "index.html", searches: searches
  end

  def delete(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    Repo.delete search
    redirect conn, external: get_refer(conn)
  end

  # TODO DRY refactor
  defp phonify(string) do
    case String.length(string) do
      11 ->
        area_code = String.slice(string, 1..3)
        prefix = String.slice(string, 4..6)
        last_four = String.slice(string, 7..10)
        "(#{area_code}) #{prefix}-#{last_four}"
      10 ->
        area_code = String.slice(string, 0..2)
        prefix = String.slice(string, 3..5)
        last_four = String.slice(string, 6..9)
        "(#{area_code}) #{prefix}-#{last_four}"
      _ ->
        "error"
    end
  end

  # TODO DRY refactor
  defp get_refer(conn) do
    {_, referer} = List.keyfind(conn.req_headers, "referer", 0) || {0, search_path(conn, :index)}
    referer
  end
end
