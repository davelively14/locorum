defmodule Locorum.BackendSys do
  alias Locorum.{ResultCollection, Repo, Backend}
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

  # Determine the options, broadcast to channel to setup everything, then call
  # the Supervisor to run the backends.
  # NOTE as we adjust broadcasts, ensure we do so in the JS, too
  def compute(query, socket, opts \\ []) do

    limit = opts[:limit] || 10

    backends = opts[:backends] || Repo.all(Backend) |> Enum.map(&(Map.get(&1, :module) |> String.to_atom))
    # TODO remove this
    # backends = [Locorum.BackendSys.Yelp, Locorum.BackendSys.Mapquest, Locorum.BackendSys.Neustar, Locorum.BackendSys.Google, Locorum.BackendSys.Facebook, Locorum.BackendSys.Yahoo, Locorum.BackendSys.Bing, Locorum.BackendSys.CityGrid]

    # TODO delete. Start the app in mix.exs now
    # HTTPoison.start

    changeset = ResultCollection.changeset(%ResultCollection{search_id: query.id}, %{search_id: query.id})
    result_collection_id =
      case Repo.insert(changeset) do
        {:ok, result_collection} ->
          result_collection.id
        {:error, changeset} ->
          IO.inspect(changeset.errors)
      end

    socket = assign(socket, :result_collection_id, result_collection_id)
    project_id = socket.assigns.project_id
    # TODO fix user_id, just using a known temp right now
    user_id = 1

    backends |> Enum.each(&(Repo.get_by!(Backend, module: Atom.to_string(&1)) |> init_frontend(query, user_id, socket)))

    # TODO remove
    # Don't think we need spawn_query any more, we're just going to call the
    # Supervise function for everything.
    # backends
    # |> Enum.map(&spawn_query(&1, query, socket, limit))
    # {:ok, pid} =
      Locorum.BackendSys.BackendsSupervisor.start_link(project_id, query, socket, backends)
    # Process.monitor(pid)
  end

  # Added for_user to allow the client to identify if the broadcast is meant for
  # them or not. Otherwise, this allows the client to initialize each frontend.
  # TODO determine if we need to do this, or if the client will load all backends
  defp init_frontend(backend, query, user_id, socket) do
    broadcast! socket, "backend", %{
      for_user: user_id,
      backend: backend.name,
      backend_str: backend.name_str,
      url_site: backend.url,
      url_search: "#",
      search_id: query.id
    }
  end

  # TODO So...what does this do? Originally, the Supervisor would just monitor this process for some reason
  # Originally, Locorum.BackendSys.Supervisor would only supervise one type of
  # worker (BackendSys module), which allowed us to use :simple_one_for_one IOT
  # allow for dynamic creation of workers. This won't work for backends, but it
  # does work for the BackendSys portion of our supervision.
  # TODO delete this
  # defp spawn_query(backend, query, socket, limit) do
  #   query_ref = make_ref()
  #   opts = [backend, query, query_ref, socket, limit]
  #   {:ok, pid} = Supervisor.start_child(Locorum.BackendSys.Supervisor, opts)
  #   monitor_ref = Process.monitor(pid)
  #   {pid, monitor_ref, query_ref}
  # end
end
