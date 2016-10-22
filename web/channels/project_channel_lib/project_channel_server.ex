defmodule Locorum.ProjectChannelServer do
  use GenServer
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

  # TODO determine if we use GenServer state or :ets for data storage
  # This will pull all results_collections, backends, and associations and store
  # in state. Or should it be :ets?
  def init_state(project_id) do
    [project_id]
  end

  # Given a project_id, this will return the name of the channel server for
  # the project.
  def name(project_id) do
    :"Project#{project_id}Server"
  end
end
