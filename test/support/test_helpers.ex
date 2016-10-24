defmodule Locorum.TestHelpers do
  alias Locorum.{Repo, User, Project, Search, ResultCollection, Result}

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

  def insert_search(attrs \\ %{}) do
    changes = Dict.merge(%{
      address1: "1280 W Peachtree St NW, unit 3009",
      biz: "Lively Unlimited",
      city: "Atlanta",
      state: "GA",
      phone: "4043196678",
      zip: "30309",
      project_id: 1
    }, attrs)

    %Search{}
    |> Search.changeset(changes)
    |> Repo.insert!
  end

  def insert_results(search_id, num_results) do
    # TODO see which ones need to have search_id
    changes = %{search_id: search_id}
    collection =
      %ResultCollection{search_id: search_id}
      |> ResultCollection.changeset(changes)
      |> Repo.insert!

    for _x <- 1..num_results do
      changes = %{
        address: "5724 Shadow Creek Rd",
        backend_id: 0,
        city: "Atlanta",
        state: "GA",
        zip: "30312",
        name: "Something or Other",
        phone: "4042607121",
        rating: "75",
        result_collection_id: collection.id,
        url: "http://www.somethingorother.com"
      }

      %Result{}
      |> Result.changeset(changes)
      |> Repo.insert!
    end
  end

  def insert_full_project do
    user = insert_user
    project = insert_project

    search1 = insert_search(%{project_id: project.id, user_id: user.id})
    search2 = insert_search(%{
                project_id: project.id,
                user_id: user.id,
                address1: "369 Loomis Ave SE",
                zip: "30312",
                phone: "4042773445",
                biz: "Cronin Around"
              })

    insert_results(search1.id, 5)
    insert_results(search2.id, 5)

    project
  end
end
