defmodule Locorum.NoResultsView do
  use Locorum.Web, :view

  def render("no_result.json", %{no_results: nr}) do
    %{
      reason: nr.reason,
      backend: nr.backend.name
    }
  end
end
