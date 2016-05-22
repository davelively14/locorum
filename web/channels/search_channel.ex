defmodule Locorum.SearchChannel do
  alias Locorum.Search
  alias Locorum.Repo
  alias Locorum.ResultCollection
  use Locorum.Web, :channel

  def join("searches:" <> search_id, _params, socket) do

    {:ok, assign(socket, :search_id, search_id)}
  end

  def handle_in("run_search", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }

    search = Repo.get!(Search, socket.assigns.search_id)
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)
    {:reply, :ok, socket}
  end

  # def handle_out("result", payload, socket) do
  #   payload["search_id"]
  #   |> check_max
  #
  #   changeset = Result.changeset(%Result{}, payload)
  #   case Repo.insert(changeset) do
  #     {:ok, _result} ->
  #       push socket, "result", payload
  #       {:noreply, socket}
  #     {:error, changeset} ->
  #       push socket, "error", %{
  #         error: changeset.errors
  #       }
  #   end
  # end
end
