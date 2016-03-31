defmodule Locorum.ResultsController do
  use Locorum.Web, :controller
  alias Locorum.Search

  def show(conn, %{"id" => id}) do
    search = Repo.get!(Search, id)
    render conn, "show.html", search: search
  end
end
