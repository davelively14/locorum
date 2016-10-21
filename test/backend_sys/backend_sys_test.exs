defmodule Locorum.BackendSysTest do
  use Locorum.ChannelCase, asynch: true
  alias Locorum.Backend
  alias Locorum.BackendSys.Helpers
  # alias Locorum.BackendSys
  alias Locorum.Search

  @backends [
    %Backend{module: "Elixir.Locorum.BackendSys.CityGrid", name: "city_grid", name_str: "CitySearch / CityGrid", url: "http://www.citysearch.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Google", name: "google", name_str: "Google", url: "https://www.google.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Local", name: "local", name_str: "Local", url: "http://www.local.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.WhitePages", name: "white_pages", name_str: "White Pages", url: "http://www.whitepages.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Yahoo", name: "yahoo", name_str: "Yahoo Local", url: "https://local.yahoo.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Yp", name: "yp", name_str: "Yellow Pages", url: "http://www.yellowpages.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Bing", name: "bing", name_str: "Bing", url: "https://www.bing.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Neustar", name: "neustar", name_str: "Neustar Localeze", url: "https://www.neustarlocaleze.biz"},
    %Backend{module: "Elixir.Locorum.BackendSys.Facebook", name: "facebook", name_str: "Facebook", url: "https://www.facebook.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Yelp", name: "yelp", name_str: "Yelp", url: "https://www.yelp.com"},
    %Backend{module: "Elixir.Locorum.BackendSys.Mapquest", name: "mapquest", name_str: "MapQuest", url: "https://www.mapquest.com"}
  ]

  @query %Search{id: 1, biz: "Lucas Group", address1: "950 E Paces Ferry Rd, Ste 2300", address2: nil, city: "Atlanta", state: "GA", zip: "30326", phone: "4042607121", project_id: 1, user_id: 3}

  HTTPoison.start

  for backend <- @backends do
    # Only way I've found to dynamically pass backend to the test. Setup doesn't really work.
    @backend backend

    @tag :backends
    @tag :external
    test "backend #{backend.name_str} is running" do
      url = apply(String.to_existing_atom(@backend.module), :get_url, [@query])
      result =
        cond do
          url =~ "/www" ->
            Helpers.fetch_html(url)
          true ->
            Helpers.fetch_json(url)
        end

      assert result
      # assert_raise UndefinedFunctionError, apply(String.to_existing_atom(@backend.module), :fetch, [@query, nil, %Phoenix.Socket{}, nil])
      # Assert received the result?
      # Or just see what the result is...
    end
  end
end
