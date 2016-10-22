defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase

  @project_id 1

  @tag :project_server
  test "get_state returns [Locorum.ProjectChannelServerj]", %{conn: _conn} do
    Locorum.ProjectChannelSupervisor.start_link(@project_id)
    [result] = Locorum.ProjectChannelServer.get_state(@project_id)
    assert result == @project_id && result |> is_integer
  end
end
