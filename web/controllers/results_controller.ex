defmodule Locorum.ResultsController do
  use Locorum.Web, :controller
  alias Locorum.Search

  def show(conn, %{"id" => id}) do
    search = Repo.get!(Search, id)
    search = Map.put(search, :phone, phonify(search.phone))
    render conn, "show.html", search: search
  end

  defp phonify(string) do
    case String.length(string) do
      11 ->
        area_code = String.slice(string, 1..3)
        prefix = String.slice(string, 4..6)
        last_four = String.slice(string, 7..10)
        "(#{area_code}) #{prefix}-#{last_four}"
      10 ->
        area_code = String.slice(string, 0..2)
        prefix = String.slice(string, 3..5)
        last_four = String.slice(string, 6..9)
        "(#{area_code}) #{prefix}-#{last_four}"
      _ ->
        "error"
    end
  end
end
