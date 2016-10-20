defmodule Locorum.ProjectChannelSupervisor do
  use Supervisor

  #######
  # API #
  #######

  def start_link(project_id) do
    Supervisor.start_link(__MODULE__, project_id, name: :"Project#{project_id}Supervisor")
  end

  #############
  # Callbacks #
  #############

  def init(project_id) do
    child_opts = [
      restart: :permanent,
      function: :start_link,
      shutdown: :infinity
    ]

    children = [
      worker(Locorum.ProjectChannelServer, [project_id], child_opts)
    ]

    supervise_opts = [
      strategy: :one_for_one
    ]

    supervise(children, supervise_opts)
  end
end
