defmodule Locorum.ResultCollectionView do
  use Locorum.Web, :view

  def render("result_collection.json", %{result_collection: c}) do
    %{
      search_id: c.search_id,
      results: render_many(c.results, Locorum.ResultsView, "result.json")
    }
  end
end
