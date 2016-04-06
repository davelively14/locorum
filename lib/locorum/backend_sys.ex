defmodule Locorum.BackendSys do
  def start(_type, _args) do
    Locorum.BackendSys.start_link()
  end

  # TODO: replace this with a Repo call to backends persisted in db?
  @backends [Locorum.BackendSys.WhitePages]

  defmodule Result do
    defstruct biz: nil, address: nil, city: nil, state: nil, zip: nil, backend: nil
  end

  def start_link(backend, query, query_ref, owner, limit) do
    backend.start_link(query, query_ref, owner, limit)
  end

  def compute(query, opts \\ []) do
    limit = opts[:limit] || 10
    backends = opts[:backends] || @backends

    backends
    |> Enum.map(&spawn_query(&1, query, limit))
  end

  defp spawn_query(backend, query, limit) do
    query_ref = make_ref()
    opts = [backend, query, query_ref, self(), limit]
    {:ok, pid} = Supervisor.start_child(Locorum.BackendSys.Supervisor, opts)
    {pid, query_ref}
  end
end
