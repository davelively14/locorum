defmodule Locorum.SessionController do
  use Locorum.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Locorum.Auth.login_by_username_and_password(conn, user, pass, repo: Locorum.Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "#{user} logged in")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid username/password")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Locorum.Auth.logout
    |> redirect(to: page_path(conn, :index))
  end
end
