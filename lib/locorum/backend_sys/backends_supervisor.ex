defmodule Locorum.BackendSys.BackendsSupervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(query, socket, backends) do
    Supervisor.start_link(__MODULE__, [query, socket, backends], name: :"BackendsSupervisor#{socket.assigns.project_id}-#{query.id}")
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
      # Add in a worker server to capture exits.
      # |> :erlang.++(worker(MODULE, args, opts))

    # TODO delete this. Can't get it to work
    # children = [
    #   worker(Locorum.BackendSys.BackendsServer, [self, query, socket, backends])
    # ]

    # :one_for_all ensure that if the BackendsServer goes down, we restart it
    # all. Ensures that we don't get partial results form any search. Not sure
    # if this is the right thing to do, though. Will need to experiment.
    options = [
      strategy: :one_for_one,
      shutdown: 7_000
    ]

    supervise children, options
  end
end
