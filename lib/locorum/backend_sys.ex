defmodule Locorum.BackendSys do
  alias Locorum.ResultCollection
  alias Locorum.Repo
  use Phoenix.Channel

  def join(_, _, _), do: nil

  def start(_type, _args) do
    Locorum.BackendSys.start_link()
  end

  # TODO uncomment WhitePages once backend fixed
  @backends [Locorum.BackendSys.Google,
             Locorum.BackendSys.Yahoo,
             Locorum.BackendSys.Bing,
             Locorum.BackendSys.CityGrid,
             Locorum.BackendSys.Neustar,
             Locorum.BackendSys.Facebook,
             Locorum.BackendSys.Yp,
             Locorum.BackendSys.Yelp,
             Locorum.BackendSys.Local]

            #  Locorum.BackendSys.WhitePages]

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
    backends = opts[:backends] || @backends
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

    backends
    # TODO should this call a Task.start_link?
    |> Enum.map(&spawn_query(&1, query, socket, limit))
    # |> Enum.map(&monitor_spawns(&1, opts))
  end

  defp spawn_query(backend, query, socket, limit) do
    query_ref = make_ref()
    opts = [backend, query, query_ref, socket, limit]
    {:ok, pid} = Supervisor.start_child(Locorum.BackendSys.Supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, query_ref}
  end
end
