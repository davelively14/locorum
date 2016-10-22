defmodule Locorum.ProjectChannelServer do
  use GenServer
  import Ecto.Query, only: [from: 2]
  alias Locorum.Repo
  alias Locorum.ResultCollection
  alias Locorum.Backend
  alias Locorum.Search
  alias Locorum.Result

  #######
  # API #
  #######

  def start_link(project_id) do
    GenServer.start_link(__MODULE__, project_id, name: :"Project#{project_id}Server")
  end

  def get_state(project_id) do
    GenServer.call(name(project_id), :get_state)
  end

  #############
  # Callbacks #
  #############

  def init(project_id) do
    state = init_state(project_id)

    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  #####################
  # Private Functions #
  #####################

  # TODO convert to :ets for data storage
  # This will pull all results_collections, backends, and associations and store
  # in state. Or should it be :ets?
  def init_state(project_id) do
    preload_collections = from rc in ResultCollection, order_by: [desc: rc.inserted_at]
    preload_results = from r in Result, order_by: [desc: r.rating]
    searches = Repo.all from s in Search,
                        where: s.project_id == ^project_id,
                        preload: [result_collections: ^preload_collections, result_collections: [results: ^preload_results, results: :backend]]
    backends = Backend |> Repo.all

    collections =
      searches
      |> Enum.map(&(&1.result_collections))
      |> List.flatten

    first_collections =
      searches
      |> Enum.map(&(List.first(&1.result_collections)))

    if List.first(collections) do
      %{collections: Phoenix.View.render_many(first_collections, Locorum.ResultCollectionView, "result_collection.json"),
        collection_list: Phoenix.View.render_many(collections, Locorum.ResultCollectionView, "result_collection_list.json"),
        backends: Phoenix.View.render_many(backends, Locorum.BackendView, "backend.json")}
    else
      %{collections: [], collection_list: [], backends: []}
    end
  end

  # Given a project_id, this will return the name of the channel server for
  # the project.
  def name(project_id) do
    :"Project#{project_id}Server"
  end
end
