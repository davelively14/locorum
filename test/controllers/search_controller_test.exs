defmodule Locorum.SearchControllerTest do
  use Locorum.ConnCase
  alias Locorum.Search

  @valid_attributes %{biz: "A Biz Name", zip: "34593", city: "Atlanta", state: "GA"}
  @invalid_attributes %{zip: "1234"}

  test "creates search and redirects" do
    
  end
end
