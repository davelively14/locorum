defmodule Locorum.BackendSys.Google do
  alias Locorum.BackendSys.Helpers
  alias Locorum.BackendSys.Header
  alias Locorum.BackendSys.Result

  @backend %Header{backend: "google", backend_str: "Google", url_site: "https://www.google.com"}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    get_url(query)
    |> Helpers.init_json(@backend, owner)
    |> parse_data
    |> Helpers.send_results(@backend, owner, query)
  end

  defp get_url(query) do
    city =
      query.city
      |> Helpers.convert_to_utf("%20")
    state = query.state
    biz =
      query.biz
      |> Helpers.convert_to_utf("%20")

    "https://maps.googleapis.com/maps/api/place/textsearch/json?key=#{get_key}&query=#{biz}%20#{city}%20#{state}"
  end

  defp get_key, do: Application.get_env(:locorum, :google)[:key]

  defp parse_data(body) do
    result = Poison.decode!(body)
    result["results"]
    |> add_to_results
  end

  defp add_to_results([]), do: []
  defp add_to_results([head|tail]) do
    full =
      head["formatted_address"]
      |> String.split(", ")
    address = Enum.at(full, 0)
    city = Enum.at(full, 1)
    state_zip =
      Enum.at(full, 2)
      |> String.split(" ")
    state = Enum.at(state_zip, 0)
    zip = Enum.at(state_zip, 1)
    [%Result{biz: head["name"], address: address, city: city, state: state, zip: zip} | add_to_results(tail)]
  end
end
