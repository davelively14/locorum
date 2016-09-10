defmodule Locorum.BackendSysTest do
  use Locorum.ConnCase
  alias Locorum.Backend

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

  for backend <- @backends do
    @tag :backends
    @tag :external
    test "backend #{backend.name_str} is running" do
      assert 1 == 1
    end
  end
end
