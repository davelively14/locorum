defmodule Locorum.BackendSys.BackendsSupervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(project_id, query, socket, backends) do
    Supervisor.start_link(__MODULE__, [query, socket, backends], name: :"BackendsSupervisor#{project_id}-#{query.id}")
  end

  #############
  # Callbacks #
  #############

  def init([query, socket, backends]) do

    # Creates a list of worker functions that will call:
    # worker(Locorum.BackendSys.SomeBackend, [query, nil, socket, nil], restart: permanent)
    # We're passing the nils in place of query_ref and limit, as they have not
    # been implemented in the backends.
    children =
      backends
      |> Enum.map(&worker(&1, [query, nil, socket, nil], restart: :transient))

    # TODO delete the old one
    # children = [
    #   worker(Locorum.BackendSys, [], restart: :transient)
    # ]

    supervise children, strategy: :one_for_one
  end
end
