defmodule Locorum.ResultsView do
  use Locorum.Web, :view
  alias Locorum.Repo
  alias Locorum.Backend

  def render("result.json", %{results: r}) do
    %{
      backend: r.backend.name,
      backend_str: r.backend.name_str,
      backend_url: r.backend.url,
      biz: r.name,
      address: r.address,
      city: r.city,
      state: r.state,
      zip: r.zip,
      rating: r.rating,
      url: r.url,
      phone: r.phone,
      search_id: r.search_id
    }

  end
end
