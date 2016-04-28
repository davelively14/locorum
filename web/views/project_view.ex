defmodule Locorum.ProjectView do
  use Locorum.Web, :view

  def get_username(id) do
    user =
      Locorum.User
      |> Locorum.Repo.get(id)
    user.username
  end
end
