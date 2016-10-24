defmodule Locorum.TestHelpers do
  alias Locorum.Repo
  alias Locorum.User
  alias Locorum.Project
  alias Locorum.Search
  alias Locorum.ResultCollection
  alias Locorum.Result

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
      project_id: 1,
      user_id: 1
    }, attrs)

    %Search{}
    |> Search.changeset(changes)
    |> Repo.insert!
  end

  def insert_results(search_id, num_results) do
    # TODO see which ones need to have search_id
    changes = %{search_id: search_id}
    collection =
      %ResultCollection{}
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
        rating: 75,
        result_collection_id: collection.id,
        url: "http://www.somethingorother.com"
      }
    end
  end

  def insert_full_project do
    project = insert_project

    search1 = insert_search(%{project_id: project.id})
    search2 = insert_search(%{
                project_id: project.id,
                address1: "369 Loomis Ave SE",
                zip: "30312",
                phone: "4042773445",
                biz: "Cronin Around"
              })

    insert_results(search1.id, 5)
    insert_results(search2.id, 5)

    {:ok, project}
  end
end
