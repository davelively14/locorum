defmodule Locorum.UserController do
  use Locorum.Web, :controller
  alias Locorum.User
  alias Locorum.Repo

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created")
        |> redirect(to: search_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end

  end
end
