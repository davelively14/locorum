defmodule Locorum.TestHelpers do
  alias Locorum.Repo
  alias Locorum.User
  alias Locorum.Project

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Random User",
      username: "user#{Base.encode16(:crypto.rand_bytes(8))}",
      password: "password"
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!
  end

  def insert_project(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "New Project"
    }, attrs)

    %Project{}
    |> Project.changeset(changes)
    |> Repo.insert!
  end
end
