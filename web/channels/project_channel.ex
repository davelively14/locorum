defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel

  def join("projects:" <> project_id, _params, socket) do
    {:ok, assign(socket, :project_id, project_id)}
  end

  def handle_in("run_test", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }
  end
end
