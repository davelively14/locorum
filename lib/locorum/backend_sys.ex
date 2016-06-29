defmodule Locorum.BackendSys do
  alias Locorum.ResultCollection
  alias Locorum.Repo
  alias Locorum.Backend
  use Phoenix.Channel

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

  def compute(query, socket, opts \\ []) do
    limit = opts[:limit] || 10
    backends = opts[:backends] || Repo.all(Backend) |> Enum.map(&(Map.get(&1, :module) |> String.to_atom))
    HTTPoison.start

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

    backends
    |> Enum.map(&spawn_query(&1, query, socket, limit))
  end

  defp init_frontend(backend, query, socket) do
    broadcast! socket, "backend", %{
      backend: backend.name,
      backend_str: backend.name_str,
      url_site: backend.url,
      url_search: "#",
      search_id: query.id
    }
  end

  defp spawn_query(backend, query, socket, limit) do
    query_ref = make_ref()
    opts = [backend, query, query_ref, socket, limit]
    {:ok, pid} = Supervisor.start_child(Locorum.BackendSys.Supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, query_ref}
  end
end
