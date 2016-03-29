defmodule Locorum.SearchController do
  use Locorum.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end
end
