defmodule Locorum.ProjectChannelServer do
  use GenServer
  use Phoenix.Channel, only: [broadcast!: 3]
  import Ecto.Query, only: [from: 2]
  alias Locorum.{Repo, ResultCollection, Backend, Search, Result, BackendSysSupervisor}

  #######
  # API #
  #######

  # TODO add docs for each function
  # Any function starting with "get" is a synchronous call. Any function
  # starting with "fetch" is an asynchronous call.

  # Starts the server
  def start_link(project_id) do
    GenServer.start_link(__MODULE__, project_id, name: :"Project#{project_id}Server")
  end

  # Returns the entire state of the server. Used for diagnostics and testing.
  def get_state(project_id) do
    GenServer.call(name(project_id), :get_state)
  end

  # Gets the "deprecated" version of the state. Basically, returns the info we
  # used to want in our older version (straight to Repo).
  # TODO rename this. We'll still need to use it for this version
  def get_dep_state(project_id) do
    GenServer.call(name(project_id), :get_dep_state)
  end

  # Confirms that a server for a given project_id is online and running.
  def is_online(project_id) do
    if GenServer.whereis(name(project_id)), do: true, else: false
  end

  # Returns a list of Search objects for a given project
  def get_searches(project_id) do
    GenServer.call(name(project_id), :get_searches)
  end

  # Provided a project_id and search_id, will return a single Search object
  def get_single_search(project_id, search_id) do
    GenServer.call(name(project_id), {:get_single_search, search_id})
  end

  # Retrieves the most recent search results for a given project. Once a user
  # is notified that updated resutls for a given project exist, this will allow
  # the user to retrieve all of the updates for a given project.
  def get_updated_results(project_id) do
    GenServer.call(name(project_id), :get_updated_results)
  end

  # Like get_updated_results, but instead only returns updated results for a
  # single search.
  def get_updated_result(project_id, search_id) do
    GenServer.call(name(project_id), {:get_updated_result, search_id})
  end

  # Returns a specific ResultsCollection. Used to retrieve older results.
  def fetch_collection(socket, collection_id) do
    GenServer.cast(name(socket.assigns.project_id), {:fetch_collection, socket, collection_id})
  end

  # Asynchronously runs one or all searches for a project via BackendSys.
  def fetch_new_results(socket, search_id \\ nil) do
    GenServer.cast(name(socket.assigns.project_id), {:fetch_new_results, socket, search_id})
  end

  # Given a project_id, this will return the name of the channel server for
  # the project.
  def name(project_id) do
    :"Project#{project_id}Server"
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

  def handle_call(:get_dep_state, _from, %{newest_collections: collections, collection_list: collection_list, backends: backends} = state ) do
    dep_state = %{collections: collections, collection_list: collection_list, backends: backends}
    {:reply, dep_state, state}
  end

  def handle_call(:get_searches, _from, %{searches: searches} = state) do
    {:reply, searches, state}
  end

  def handle_call({:get_single_search, search_id}, _from, %{searches: searches} = state) when is_integer(search_id) do
    search = searches |> Enum.find(&(&1.id == search_id))
    {:reply, search, state}
  end

  def handle_call({:get_single_search, search_id}, _from, %{searches: searches} = state) do
    search = get_search(searches, search_id)
    {:reply, search, state}
  end

  def handle_call(:get_updated_results, _from, %{newest_collections: collections} = state) do
    {:reply, collections, state}
  end

  def handle_call({:get_updated_result, search_id}, _from, %{newest_collections: collections} = state) when is_integer(search_id) do
    collection = collections |> Enum.find(&(&1.search_id == search_id))
    {:reply, collection, state}
  end

  def handle_call({:get_updated_result, search_id}, _from, %{newest_collections: collections} = state) do
    collection = collections |> Enum.find(&(&1.search_id == String.to_integer(search_id)))
    {:reply, collection, state}
  end

  def handle_cast({:fetch_collection, socket, collection_id}, %{all_collections: collections} = state) do
    [{_, collection}] = :ets.lookup(collections, collection_id)
    resp = %{collection: collection, user_id: socket.assigns.user_id}
    Phoenix.Channel.broadcast!(socket, "render_collection", resp)
    {:noreply, state}
  end

  def handle_cast({:fetch_new_results, socket, search_id}, %{searches: searches} = state) do

    # Returns all searches if search_id is nil, otherwise it will call the
    # private function get_search/3 and return the result inside a list. We
    # return it in a list because that's what compute expects.
    searches =
      case search_id do
        nil ->
          searches
        _ ->
          [get_search(searches, search_id)]
      end

    {:ok, pid} = BackendSysSupervisor.start_link(searches, socket)
    Process.monitor(pid)

    {:noreply, state}
  end

  # Handles responses from the individual backends, updates the state, and then
  # broadcasts to the socket.
  def handle_cast({:receive_result, socket, payload}, state) do
    for result <- payload.results do
      broadcast! socket, "result", result
    end

    broadcast! socket, "loaded_results", payload.loaded_message

    {:noreply, state}
  end

  # If there is not a result, this will let the channel know.
  def handle_cast({:no_result, socket, payload}, state) do
    broadcast! socket, "no_result", payload.no_result
    broadcast! socket, "loaded_results", payload.loaded_message

    {:noreply, state}
  end

  # TODO implement backend crash handling
  # Not impelemented yet. If a backend crashes, the supervisor will notifiy the
  # server that it failed and the server will notify the channel.
  # We need to do this from BackendsSupervisor
  def handle_cast({:backend_error, socket}, state) do
    _ = socket
    {:noreply, state}
  end

  #####################
  # Private Functions #
  #####################

  # This will pull all results_collections, backends, and associations and store
  # in state and :ets
  defp init_state(project_id) do

    # Write the queries for preloading ResultCollection and Result for all
    # searches for a given project. Sorts are key here, as they will order the
    # results by most recent.
    preload_collections = from rc in ResultCollection, order_by: [desc: rc.inserted_at]
    preload_results = from r in Result, order_by: [desc: r.rating]

    # We don't preload here in order to capture searches for storage separately
    # in the server's state.
    searches = Repo.all from s in Search, where: s.project_id == ^project_id

    # Now we preload all the searches to eventually store them in state.
    preloaded_searches =
      searches
      |> Repo.preload([result_collections: preload_collections, result_collections: [results: preload_results, results: :backend]])

    # Loads all backends to store in state.
    backends = Backend |> Repo.all

    # Pulls all result_collections from t
    collections =
      preloaded_searches
      |> Enum.map(&(&1.result_collections))
      |> List.flatten

    # Pulls the most recent result collections for each search.
    newest_collections =
      preloaded_searches
      |> Enum.map(&(List.first(&1.result_collections)))

    # Creates :ets table :all_collections if it does not already exist
    if :ets.info(:all_collections) == :undefined, do: :ets.new(:all_collections, [:set, :private, :named_table])

    # Stores each collection in an :ets table
    # collections |> Enum.each(&(:ets.insert(:all_collections, {&1.id, &1.search_id, &1.results})))
    collections
    |> Enum.each(&store_collection(&1, :all_collections))

    # Uses JSON rendering from the views in order to construct the state as a
    # JSON object. If there are n collections, will return object with empty
    # values
    if List.first(collections) do
      %{all_collections: :all_collections,
        newest_collections: Phoenix.View.render_many(newest_collections, Locorum.ResultCollectionView, "result_collection.json"),
        collection_list: Phoenix.View.render_many(collections, Locorum.ResultCollectionView, "result_collection_list.json"),
        searches: searches,
        backends: Phoenix.View.render_many(backends, Locorum.BackendView, "backend.json")}
    else
      %{all_collections: [], searches: [], newest_collections: [], collection_list: [], backends: []}
    end
  end

  defp store_collection(collection, table_name) do
    collection = Phoenix.View.render(Locorum.ResultCollectionView, "result_collection.json", result_collection: collection)
    :ets.insert(table_name, {collection.id, collection})
  end

  # Given a list of searches, will return the search matching search_id
  defp get_search(searches, search_id) when is_bitstring(search_id), do: searches |> Enum.find(&(&1.id == String.to_integer(search_id)))
  defp get_search(searches, search_id) when is_integer(search_id), do: searches |> Enum.find(&(&1.id == search_id))
end
