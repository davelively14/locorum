defmodule Locorum.ZipLocateTest do
  use ExUnit.Case, async: true
  alias Locorum.ZipLocate

  setup do
    {:ok, agent} = ZipLocate.start_link
    {:ok, agent: agent}
  end

  test "stores value by key", %{agent: agent} do
    assert ZipLocate.get(agent, "99999") == nil

    ZipLocate.put(agent, "99999", {"89.123", "-82.332"})
    assert ZipLocate.get(agent, "99999") == {"89.123", "-82.332"}
  end

  test "receives coords for 30312 by default", %{agent: agent} do
    assert is_tuple(ZipLocate.get(agent, "30312"))
  end
end
