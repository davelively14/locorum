defmodule Locorum.BackendView do
  use Locorum.Web, :view

  def render("backend.json", %{backend: b}) do
    %{
      backend: b.name,
      backend_str: b.name_str,
      url_site: b.url
    }
  end
end
