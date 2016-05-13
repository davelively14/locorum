defmodule Locorum.ProjectChannel do
  use Locorum.Web, :channel

  def join("projects:" <> project_id, _params, socket) do
    {:ok, assign(socket, :project_id, project_id)}
  end

  def handle_in("run_test", _params, socket) do
    broadcast! socket, "clear_results", %{
      id: nil
    }

    broadcast! socket, "backend", %{
      backend: "yahoo",
      backend_str: "Yahoo Local",
      backend_url: "http://www.yahoo.com",
      results_url: "http://www.yahoo.com/results/16",
      search_id: 92
    }

    broadcast! socket, "backend", %{
      backend: "yahoo",
      backend_str: "Yahoo Local",
      backend_url: "http://www.yahoo.com",
      results_url: "http://www.yahoo.com/results/16",
      search_id: 93
    }

    broadcast! socket, "backend", %{
      backend: "yahoo",
      backend_str: "Yahoo Local",
      backend_url: "http://www.yahoo.com",
      results_url: "http://www.yahoo.com/results/16",
      search_id: 94
    }

    broadcast! socket, "backend", %{
      backend: "google",
      backend_str: "Google",
      backend_url: "http://www.google.com",
      results_url: "http://www.google.com/results/16",
      search_id: 92
    }

    broadcast! socket, "backend", %{
      backend: "google",
      backend_str: "Google",
      backend_url: "http://www.google.com",
      results_url: "http://www.google.com/results/16",
      search_id: 93
    }

    broadcast! socket, "backend", %{
      backend: "google",
      backend_str: "Google",
      backend_url: "http://www.google.com",
      results_url: "http://www.google.com/results/16",
      search_id: 94
    }

    broadcast! socket, "result", %{
      backend: "yahoo",
      biz: "Nebo Agency",
      address: "369 Loomis Ave SE",
      city: "Atlanta",
      state: "GA",
      zip: "30312",
      rating: "83",
      url: "http://www.yahoo.com/nebo_loomis",
      phone: "(404) 260-7121",
      search_id: 92
    }

    broadcast! socket, "result", %{
      backend: "yahoo",
      biz: "Nebo Agency",
      address: "1280 W Peachtree St NW, Apt 3009",
      city: "Atlanta",
      state: "GA",
      zip: "30309",
      rating: "0",
      url: "http://www.yahoo.com/nebo_peachtree",
      phone: "(404) 277-3446",
      search_id: 92
    }

    broadcast! socket, "result", %{
      backend: "google",
      biz: "Nebo Agency",
      address: "369 Loomis Ave SE",
      city: "Atlanta",
      state: "GA",
      zip: "30312",
      rating: "83",
      url: "http://www.google.com/nebo_loomis",
      phone: "(404) 260-7121",
      search_id: 92
    }

    broadcast! socket, "result", %{
      backend: "google",
      biz: "Nebo Agency",
      address: "1280 W Peachtree St NW, Apt 3009",
      city: "Atlanta",
      state: "GA",
      zip: nil,
      rating: "0",
      url: nil,
      phone: "(404) 277-3446",
      search_id: 92
    }

    broadcast! socket, "result", %{
      backend: "yahoo",
      biz: "Lucas Group",
      address: "950 E Paces Ferry Rd, Ste 2300",
      city: "Atlanta",
      state: "GA",
      zip: "30326",
      rating: "83",
      url: "http://www.yahoo.com/lg_right",
      phone: "(404) 260-7777",
      search_id: 93
    }

    broadcast! socket, "result", %{
      backend: "yahoo",
      biz: "Lucas Group",
      address: "1801 Barret Lakes Blvd, ste 300",
      city: "Atlanta",
      state: "GA",
      zip: "30301",
      rating: "0",
      url: "http://www.yahoo.com/lg_wrong",
      phone: "(404) 277-1234",
      search_id: 93
    }

    broadcast! socket, "result", %{
      backend: "google",
      biz: "Lucas Group",
      address: "950 E Paces Ferry Rd, Ste 2300",
      city: "Atlanta",
      state: "GA",
      zip: "30326",
      rating: "83",
      url: "http://www.google.com/lg_right",
      phone: "(404) 260-7777",
      search_id: 93
    }

    broadcast! socket, "result", %{
      backend: "google",
      biz: "Lucas Group",
      address: "1801 Barret Lakes Blvd, ste 300",
      city: "Atlanta",
      state: "GA",
      zip: "30301",
      rating: "0",
      url: "http://www.google.com/lg_wrong",
      phone: "(404) 277-1234",
      search_id: 93
    }

    broadcast! socket, "result", %{
      backend: "yahoo",
      biz: "Bradley Morris",
      address: "5724 Shadow Creek Rd",
      city: "Charlotte",
      state: "NC",
      zip: "28226",
      rating: "83",
      url: "http://www.yahoo.com/lg_right",
      phone: "(704) 541-6490",
      search_id: 94
    }

    broadcast! socket, "result", %{
      backend: "yahoo",
      biz: "Bradley Morris",
      address: "5832 Ryder Ave",
      city: "Charlotte",
      state: "NC",
      zip: "28229",
      rating: "0",
      url: "http://www.yahoo.com/lg_wrong",
      phone: "(404) 277-1234",
      search_id: 94
    }

    broadcast! socket, "result", %{
      backend: "google",
      biz: "Bradley Morris",
      address: "5724 Shadow Creek Rd",
      city: "Charlotte",
      state: "NC",
      zip: "28226",
      rating: "83",
      url: "http://www.google.com/lg_right",
      phone: "(704) 541-6490",
      search_id: 94
    }

    broadcast! socket, "result", %{
      backend: "google",
      biz: "Bradley Morris",
      address: "5832 Ryder Ave",
      city: "Charlotte",
      state: "NC",
      zip: "28229",
      rating: "0",
      url: "http://www.google.com/lg_wrong",
      phone: "(404) 277-1234",
      search_id: 94
    }

    {:reply, :ok, socket}
  end
end
