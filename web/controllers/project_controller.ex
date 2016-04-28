defmodule Locorum.ProjectController do
  use Locorum.Web, :controller
  alias Locorum.Project
  alias Locorum.Repo

  plug :scrub_params, "project" when action in [:create]

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, project_params)
    case Repo.insert(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "#{project.name} created")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render "new.html", changeset: changeset
    end
  end

  def index(conn, _params) do
    projects = Repo.all(Project)
    render conn, "index.html", projects: projects
  end

  def show(conn, %{"id" => id}) do
    project = Repo.get(Project, id)
    render conn, "show.html", project: project
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get(Project, id)
    Repo.delete project
    redirect(conn, to: project_path(conn, :index))
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get(Project, id)
    changeset = Project.changeset(project)
    render conn, "edit.html", project: project, changeset: changeset
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
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
end
