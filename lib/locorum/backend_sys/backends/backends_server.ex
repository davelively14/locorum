# TODO deprecate. Can't get this to work the way we want it to.
defmodule Locorum.BackendSys.BackendsServer do
  use GenServer
  import Supervisor.Spec

  #######
  # API #
  #######

  def start_link(supe, query, socket, backends) do
    GenServer.start_link(__MODULE__, [supe, query, socket, backends], name: :"BackendsServer#{socket.assigns.project_id}-#{query.id}")
  end

  #############
  # Callbacks #
  #############

  def init([supe, query, socket, backends]) do
    Process.flag(:trap_exit, true)
    start_backends(supe, backends, query, socket)
    # Supervisor.start_child(:"BackendsServer#{socket.project_id}-#{query.id}", child_spec_or_args)
    {:ok, backends}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    IO.inspect reason

    {:noreply, state}
  end

  #####################
  # Private Functions #
  #####################

  defp start_backends(supe, backends, query, socket) do
    # TODO why is this commented out?
    # for backend <- backends do
      backend = List.first backends
      IO.inspect Atom.to_string(backend)
      child_spec = worker(backend, [query, nil, socket, nil], [restart: :transient])
      IO.inspect child_spec
      Supervisor.start_child(supe, child_spec)
    # end
  end
end
