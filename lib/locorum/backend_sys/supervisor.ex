defmodule Locorum.BackendSys.Supervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(project_id, query, socket, backends) do
    Supervisor.start_link(__MODULE__, [query, socket, backends], name: :"BackendSysSupervisor#{project_id}")
  end

  #############
  # Callbacks #
  #############

  # TODO change supervisor to call the backends
  # So I think this should work now. Eliminates the need for start_link in
  # BackendSys
  def init([query, socket, backends]) do
    children = backends |> Enum.map(&worker(&1, [query, nil, socket, nil], restart: :permanent))
    # children = [
    #   worker(Locorum.BackendSys, [], restart: :transient)
    # ]
    
    supervise children, strategy: :one_for_one
  end
end
