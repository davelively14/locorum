defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase

  @tag :project_server
  test "get_state returns [Locorum.ProjectChannelServerj]", %{conn: _conn} do
    Locorum.ProjectChannelSupervisor.start_link(1)
    assert Locorum.ProjectChannelServer.get_state(1) == [Locorum.ProjectChannelServer]
  end
end
