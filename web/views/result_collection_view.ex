defmodule Locorum.ResultCollectionView do
  use Locorum.Web, :view

  def render("result_collection.json", %{result_collection: c}) do
    %{
      search_id: c.search_id,
      results: render_many(c.results, Locorum.ResultsView, "result.json")
    }
  end

  def render("result_collection_list.json", %{result_collection: c}) do
    %{
      search_id: c.search_id,
      created: c.inserted_at,
      result_collection_id: c.id
    }
  end
end
