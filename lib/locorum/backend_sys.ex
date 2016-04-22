defmodule Locorum.BackendSys do
  def start(_type, _args) do
    Locorum.BackendSys.start_link()
  end

  # TODO: replace this with a Repo call to backends persisted in db?
  @backends [Locorum.BackendSys.Google, Locorum.BackendSys.Yahoo,
             Locorum.BackendSys.CityGrid, Locorum.BackendSys.Local,
             Locorum.BackendSys.WhitePages]

  defmodule Result do
    defstruct biz: nil, address: nil, city: nil, state: nil, zip: nil, rating: nil
  end

  defmodule Header do
    defstruct backend: nil, backend_str: nil, url_search: nil, url_site: nil
  end

  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  def compute(query, socket, opts \\ []) do
    limit = opts[:limit] || 10
    backends = opts[:backends] || @backends
    HTTPoison.start

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

  # TODO kill processes once they return results
  # defp monitor_spawns(child, _opts) do
  #   {pid, monitor_ref, query_ref} = child
  #
  #   # timeout = opts[:timeout] || 5000
  #   # timer = Process.send_after(self(), :timedout, timeout)
  #
  #   receive do
  #     {:results, ^query_ref, _header, _results } ->
  #       Process.demonitor(monitor_ref, [:flush])
  #     {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
  #       kill(pid, monitor_ref)
  #     :timedout ->
  #       kill(pid, monitor_ref)
  #   end
  # end
  #
  # defp kill(pid, monitor_ref) do
  #   Process.demonitor(monitor_ref, [:flush])
  #   Process.exit(pid, :kill)
  # end
end
