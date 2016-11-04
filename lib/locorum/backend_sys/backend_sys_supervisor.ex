defmodule Locorum.BackendSysSupervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(searches, socket) do
    Supervisor.start_link(__MODULE__, [searches, socket], name: :"BackendSysSupervisor#{socket.assigns.project_id}")
  end

  #############
  # Callbacks #
  #############

  def init([searches, socket]) do

    # Creates a list of worker functions that will call:
    # Locorum.BackendSys.compute(search, socket)
    children =
      searches
      |> Enum.map(&worker(Locorum.BackendSys, [&1, socket], [function: :compute, restart: :transient]))

    options = [
      strategy: :one_for_one,
      max_restarts: 2
    ]

    supervise(children, options)
  end

end
