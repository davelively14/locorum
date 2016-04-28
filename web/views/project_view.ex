defmodule Locorum.ProjectView do
  use Locorum.Web, :view
  alias Locorum.User
  alias Locorum.Repo

  def get_username(id) do
    user = get_user(id)
    user.username
  end

  def get_name(id) do
    user = get_user(id)
    user.name
  end

  def get_user(id) do
    user =
      User
      |> Repo.get(id)
  end
end
