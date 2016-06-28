defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel
  alias Locorum.ResultCollection
  alias Locorum.Backend
  alias Locorum.Search
  alias Locorum.Result

  def join("projects:" <> project_id, _params, socket) do
    project_id = String.to_integer(project_id)
    preload_collections = from rc in ResultCollection, order_by: [desc: rc.inserted_at]
    preload_results = from r in Result, order_by: [desc: r.rating]
    searches = Repo.all from s in Search,
                        where: s.project_id == ^project_id,
                        preload: [result_collections: ^preload_collections, result_collections: [results: ^preload_results, results: :backend]]
    backends = Backend |> Repo.all


    # TODO refactor to avoid transversing the searches map twice
    collections =
      Enum.map(searches, fn search -> search.result_collections end)
      |> List.flatten
    first_collections = Enum.map(searches, fn search -> List.first(search.result_collections) end)
    # TODO render backends as well
    if List.first(collections) do
      resp = %{collections: Phoenix.View.render_many(first_collections, Locorum.ResultCollectionView, "result_collection.json"),
               collection_list: Phoenix.View.render_many(collections, Locorum.ResultCollectionView, "result_collection_list.json"),
               backends: Phoenix.View.render_many(backends, Locorum.BackendView, "backend.json")
             }
      {:ok, resp, assign(socket, :project_id, project_id)}
    else
      {:ok, nil, assign(socket, :project_id, project_id)}
    end
  end

  def add_search_id(collection), do: add_search_id(collection.results, collection.search_id)
  defp add_search_id([], _search_id), do: []
  defp add_search_id([head|tail], search_id), do: [Map.put_new(head, :search_id, search_id) | add_search_id(tail, search_id)]

  def handle_in("run_search", _params, socket) do
    project = Repo.get!(Locorum.Project, socket.assigns.project_id)
    searches =
      assoc(project, :searches)
      |> Repo.all

    for search <- searches, do: Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)
    {:reply, :ok, socket}
  end

  def handle_in("run_single_search", params, socket) do
    search = Repo.get!(Locorum.Search, params["search_id"])
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)

    {:reply, :ok, socket}
  end

  def handle_in("fetch_collection", params, socket) do
    preload_results = from r in Result, order_by: [desc: r.rating]
    collection = Repo.one from c in ResultCollection,
                          where: c.id == ^params["collection_id"],
                          preload: [results: ^preload_results, results: :backend]

    resp = %{collection: Phoenix.View.render(Locorum.ResultCollectionView, "result_collection.json", result_collection: collection)}

    broadcast!(socket, "render_collection", resp)

    {:noreply, socket}
  end
end
