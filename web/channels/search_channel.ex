defmodule Locorum.SearchChannel do
  alias Locorum.Search
  alias Locorum.Repo
  use Locorum.Web, :channel

  def join("searches:" <> search_id, _params, socket) do

    {:ok, assign(socket, :search_id, search_id)}
  end

  def handle_in("run_test", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }

    broadcast! socket, "backend", %{
      backend: "white_pages",
      backend_str: "White Pages",
      backend_url: "http://www.whitepages.com",
      results_url: "http://www.whitepages.com/something_else/16"
    }

    broadcast! socket, "backend", %{
      backend: "local",
      backend_str: "Local",
      backend_url: "http://www.local.com",
      results_url: "http://www.local.com/results/16"
    }

    broadcast! socket, "result", %{
      backend: "white_pages",
      biz: "Nebo Agency",
      address: "369 Loomis Ave SE",
      city: "Atlanta",
      state: "GA",
      zip: "30312"
    }

    broadcast! socket, "result", %{
      backend: "white_pages",
      biz: "Nebo Agency",
      address: "1280 W Peachtree St NW, unit 3009",
      city: "Atlanta",
      state: "GA",
      zip: "30309"
    }

    broadcast! socket, "no_result", %{
      backend: "local"
    }

    {:reply, :ok, socket}
  end

  def handle_in("run_search", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }

    search = Repo.get!(Search, socket.assigns.search_id)
    Task.start_link(fn -> Locorum.BackendSys.compute(search, socket) end)
    {:reply, :ok, socket}
  end

  def handle_in("test_rec", _params, socket) do
    broadcast! socket, "another_result", %{
      name: "Test worked"
    }
  end
end
