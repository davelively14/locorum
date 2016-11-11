defmodule Locorum.ProjectView do
  use Locorum.Web, :view
  alias Locorum.{User, Repo}

  def get_user(id) do
    user =
      User
      |> Repo.get(id)
    user
  end
end
