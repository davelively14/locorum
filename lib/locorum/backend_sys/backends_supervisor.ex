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

    # We use "shutdown: 7_000" to ensure that even the other processes can
    # finish. Otherwise, one backend failing will interrupt all the others. At
    # least, I think so. But maybe not, because that's what one_for_one should
    # do: only restarts the terminated process.
    options = [
      strategy: :one_for_one,
      shutdown: 7_000
    ]

    supervise children, options
  end
end
