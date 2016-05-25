defmodule Locorum.ResultsView do
  use Locorum.Web, :view
  alias Locorum.Repo
  alias Locorum.Backend

  def render("result.json", %{results: r}) do
    # TODO remove stupid N+1 by listing backend_id instead of backend_name. Requires refactoring all of the frontend js
    backend = Repo.get(Backend, r.backend_id)

    %{
      backend: backend.name,
      biz: r.name,
      address: r.address,
      city: r.city,
      state: r.state,
      zip: r.zip,
      rating: r.rating,
      url: r.url,
      phone: r.phone
    }

  end
end
