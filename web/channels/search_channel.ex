defmodule Locorum.SearchChannel do
  use Locorum.Web, :channel

  def join("searches:" <> search_id, _params, socket) do
    {:ok, assign(socket, :search_id, String.to_integer(search_id))}
  end
end
