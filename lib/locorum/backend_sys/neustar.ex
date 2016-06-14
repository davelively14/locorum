defmodule Locorum.BackendSys.Neustar do
  alias Locorum.BackendSys.Helpers
  alias Locorum.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    
  end
end
