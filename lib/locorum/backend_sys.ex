defmodule Locorum.BackendSys do
  def start(_type, _args) do
    Locorum.BackendSys.start_link()
  end

  # TODO: replace this with a Repo call to backends persisted in db?
  @backends [Locorum.BackendSys.WhitePages, Locorum.BackendSys.Local]

  defmodule Result do
    defstruct biz: nil, address: nil, city: nil, state: nil, zip: nil, backend: nil
  end

  # Do we want a header? Or just track the backend? Seems inefficient to maintain
  # each backend.
  # TODO: impelement Header return for backend info
  defmodule Header do
    defstruct backend: nil, url: nil
  end

  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  def compute(query, opts \\ []) do
    limit = opts[:limit] || 10
    backends = opts[:backends] || @backends

    backends
    |> Enum.map(&spawn_query(&1, query, limit))
    |> Enum.map(&handle_results(&1, opts))
  end

  defp spawn_query(backend, query, limit) do
    query_ref = make_ref()
    opts = [backend, query, query_ref, self(), limit]
    {:ok, pid} = Supervisor.start_child(Locorum.BackendSys.Supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, query_ref}
  end

  # Children are the resulting processes with monitors. Will this run all the
  # processes simultaneously, or will it run one at a time?
  # TODO: determine if this will only run one at a time, or concurrently
  defp handle_results(child, _opts) do
    {pid, monitor_ref, query_ref} = child

    # timeout = opts[:timeout] || 5000
    # timer = Process.send_after(self(), :timedout, timeout)

    receive do
      {:results, ^query_ref, header, results } ->
        Process.demonitor(monitor_ref, [:flush])
        # [first|_] = results
        # {String.to_atom(first.backend), results}
        { String.to_atom(header.backend), header, results }
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        kill(pid, monitor_ref)
      :timedout ->
        kill(pid, monitor_ref)
    end
  end

  defp kill(pid, monitor_ref) do
    Process.demonitor(monitor_ref, [:flush])
    Process.exit(pid, :kill)
  end
end
