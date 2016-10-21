defmodule Locorum.ProjectChannelServer do
  use GenServer

  #######
  # API #
  #######

  def start_link(project_id) do
    GenServer.start_link(__MODULE__, :ok, name: :"Project#{project_id}Server")
  end

  def get_state(project_id) do
    GenServer.call(name(project_id), :get_state)
  end

  #############
  # Callbacks #
  #############

  def init(:ok) do
    state = init_state()
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
  def init_state do
    [__MODULE__]
  end

  # Given a project_id, this will return the name of the channel server for
  # the project.
  def name(project_id) do
    :"Project#{project_id}Server"
  end
end
