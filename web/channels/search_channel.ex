defmodule Locorum.SearchChannel do
  use Locorum.Web, :channel

  def join("searches:" <> search_id, _params, socket) do
    search_id = String.to_integer(search_id)
    search = Repo.get!(Locorum.Search, search_id)

    resp =
      case search.address2 do
        nil ->
          %{biz: search.biz, address: search.address1, city: search.city,
                   state: search.state, zip: search.zip}
        _ ->
          %{biz: search.biz, address: "#{search.address1}, #{search.address2}",
                   city: search.city, state: search.state, zip: search.zip}
      end

    {:ok, resp, assign(socket, :search_id, search_id)}
  end

  def handle_in("ignore") do

  end
end
