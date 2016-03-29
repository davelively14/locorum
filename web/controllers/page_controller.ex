defmodule Locorum.PageController do
  use Locorum.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
