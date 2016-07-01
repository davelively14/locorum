defmodule Locorum.ResultCollectionController do
  use Locorum.Web, :controller
  alias Locorum.Repo
  alias Locorum.ResultCollection

  def index(conn, %{"id" => search_id}) do
    collections = Repo.all from c in ResultCollection,
                           where: c.search_id == ^search_id,
                           order_by: [desc: c.inserted_at]
    render conn, "index.html", collections: collections
  end

  def delete(conn, %{"id" => id}) do
    collection = Repo.get(ResultCollection, id)
    # collection =
    #   ResultCollection
    #   |> Repo.get(id)
    #   |> Repo.preload([:results])
    #
    # for result <- collection.results do
    #   Repo.delete result
    # end

    Repo.delete collection
    redirect conn, external: get_refer(conn)
  end

  # TODO DRY refactor
  defp get_refer(conn) do
    {_, referer} = List.keyfind(conn.req_headers, "referer", 0) || {0, backend_path(conn, :index)}
    referer
  end
end
