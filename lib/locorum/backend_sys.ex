defmodule Locorum.BackendSys do
  alias Locorum.{ResultCollection, Repo, Backend}
  use Phoenix.Channel, only: [broadcast!: 3]

  def join(_, _, _), do: nil

  defmodule Result do
    defstruct biz: nil, address: nil, city: nil, state: nil, zip: nil,
              rating: nil, url: nil, phone: nil
  end

  # TODO deprecate url_site once %Result{url_result} is online
  defmodule Header do
    defstruct backend: nil, backend_str: nil, url_search: nil, url_site: nil,
              search_id: nil
  end

  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  # Determine the options, broadcast to channel to setup everything, then call
  # the Supervisor to run the backends.
  def compute(query, socket, opts \\ []) do

    # TODO eventually remove. Unless we're going to implement limits.
    # limit = opts[:limit] || 10

    backends = opts[:backends] || Repo.all(Backend) |> Enum.map(&(Map.get(&1, :module) |> String.to_atom))

    changeset = ResultCollection.changeset(%ResultCollection{search_id: query.id}, %{search_id: query.id})
    result_collection_id =
      case Repo.insert(changeset) do
        {:ok, result_collection} ->
          result_collection.id
        {:error, changeset} ->
          IO.inspect(changeset.errors)
      end

    socket = assign(socket, :result_collection_id, result_collection_id)

    backends |> Enum.each(&(Repo.get_by!(Backend, module: Atom.to_string(&1)) |> init_frontend(query, socket)))

    Locorum.BackendSys.BackendsSupervisor.start_link(query, socket, backends)
  end

  # Added for_user to allow the client to identify if the broadcast is meant for
  # them or not. Otherwise, this allows the client to initialize each frontend.
  # TODO determine if we need to do this, or if the client will load all backends
  defp init_frontend(backend, query, socket) do
    broadcast! socket, "backend", %{
      for_user: socket.assigns.user_id,
      backend: backend.name,
      backend_str: backend.name_str,
      url_site: backend.url,
      url_search: "#",
      search_id: query.id
    }
  end
end
