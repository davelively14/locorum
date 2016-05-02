defmodule Locorum.ProjectController do
  use Locorum.Web, :controller
  alias Locorum.Project
  alias Locorum.Search
  alias Locorum.Repo

  plug :scrub_params, "project" when action in [:create, :update]

  # Override action function, pass current_user as third paramater to all func
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> build_assoc(:projects)
      |> Project.changeset

    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"project" => project_params}, user) do
    changeset =
      user
      |> build_assoc(:projects)
      |> Project.changeset(project_params)

    case Repo.insert(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "#{project.name} created")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render "new.html", changeset: changeset
    end
  end

  def index(conn, _params, _user) do
    projects =
      Repo.all(Project)
      |> Repo.preload(:user)
    render conn, "index.html", projects: projects
  end

  def show(conn, %{"id" => id}, user, changeset \\ nil) do
    project = Repo.get(Project, id)
    searches = Repo.all(project_searches(project))
    changeset = changeset || Search.changeset(%Search{user_id: user.id, project_id: id})
    render conn, "show.html", project: project, searches: searches, changeset: changeset, user: user
  end

  def delete(conn, %{"id" => id}, _user) do
    project = Repo.get(Project, id)
    Repo.delete project
    redirect(conn, to: project_path(conn, :index))
  end

  def edit(conn, %{"id" => id}, _user) do
    project = Repo.get(Project, id)
    changeset = Project.changeset(project)
    render conn, "edit.html", project: project, changeset: changeset
  end

  def update(conn, %{"id" => id, "project" => project_params}, _user) do
    project = Repo.get(Project, id)
    changeset = Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "#{project.name} updated")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render conn, "edit.html", project: project, changeset: changeset
    end
  end

  defp project_searches(project) do
    assoc(project, :searches)
  end
end
