defmodule Locorum.ProjectControllerServerTest do
  use Locorum.ConnCase

  @tag :project_server
  test "get_state returns [0, 1]", %{conn: conn} do
    Locorum.ProjectChannelSupervisor.start_link(1)
    assert Locorum.ProjectChannelServer.get_state(1) == [0, 1]
  end
end
