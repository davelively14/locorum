defmodule Locorum.SearchController do
  use Locorum.Web, :controller
  alias Locorum.Search
  require Logger

  plug :scrub_params, "search" when action in [:create, :update]

  def new(conn, _params) do
    user = conn.assigns.current_user
    changeset = Search.changeset(%Search{user_id: user.id})
    render conn, "new.html", changeset: changeset
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
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    changeset = Search.changeset(search)
    {_, referer} = List.keyfind(conn.req_headers, "referer", 0)
    cancel_action =
      cond do
        referer =~ "manage/search/" ->
          search_path(conn, :show, search)
        true ->
          search_path(conn, :index)
      end
    render conn, "edit.html", search: search, changeset: changeset, cancel_action: cancel_action
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
    render conn, "show.html", search: search
  end

  def index(conn, _params) do
    searches = Repo.all(Search)
    render conn, "index.html", searches: searches
  end

  def delete(conn, %{"id" => id}) do
    search = Repo.get(Search, id)
    project = search.project_id
    Repo.delete search
    {_, referer} = List.keyfind(conn.req_headers, "referer", 0)
    cond do
      referer =~ "manage/project" ->
        redirect(conn, to: project_path(conn, :show, project))
      true ->
        redirect(conn, to: search_path(conn, :index))
    end
  end

  # TODO DRY this
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
end
