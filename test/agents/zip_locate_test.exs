defmodule Locorum.ZipLocateTest do
  use ExUnit.Case, async: true
  alias Locorum.ZipLocate

  test "stores value by key" do
    {:ok, agent} = ZipLocate.start_link
    assert ZipLocate.get(agent, "99999") == nil

    ZipLocate.put(agent, "99999", {"89.123", "-82.332"})
    assert ZipLocate.get(agent, "99999") == {"89.123", "-82.332"}
  end

  test "receives coords for 30312 by default" do
    {:ok, agent} = ZipLocate.start_link
    assert is_tuple(ZipLocate.get(agent, "30312"))
  end
end
