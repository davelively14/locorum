defmodule Locorum.BackendSys.Google do
  alias Locorum.BackendSys.{Helpers, Result}

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query, _query_ref, owner, _limit) do
    query
    |> get_url
    |> Helpers.fetch_json
    |> parse_data
    |> Helpers.display_results(__MODULE__, owner, query, get_url(query))
  end

  def get_url(query) do
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

  def parse_data(body) do
    result = Poison.decode!(body)
    result["results"]
    |> get_place_results
    |> add_to_results
  end

  defp get_place_results([]), do: []
  defp get_place_results([head|tail]) do
    result =
      get_details_url(head["place_id"])
      |> Helpers.fetch_json
      |> Poison.decode!
    [result|get_place_results(tail)]
  end

  def get_details_url(place_id), do: "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&key=#{get_key}"

  defp add_to_results([]), do: []
  defp add_to_results([head|tail]) do
    url = head["result"]["url"]
    biz = head["result"]["name"]
    phone = head["result"]["formatted_phone_number"]
    street_number = get_item(head, "street_number")
    route = get_item(head, "route")
    address2 = get_item(head, "subpremise")
    address =
      case address2 do
        nil ->
          case street_number && route do
            nil ->
              {_, answer} = Enum.fetch(String.split(head["result"]["adr_address"], ","), 0)
              answer
            _ -> "#{street_number} #{route}"
          end
        _ -> "#{street_number} #{route} #{address2}"
      end
    city = get_item(head, "locality")
    state = get_item(head, "administrative_area_level_1")
    zip = get_item(head, "postal_code")

    [%Result{biz: biz, address: address, city: city, state: state, zip: zip, url: url, phone: phone} | add_to_results(tail)]
  end

  def get_item(head, string) do
    addresses = head["result"]["address_components"]
    result = Enum.filter(addresses, fn(x) -> Enum.any?(x["types"], fn(y) -> y == string end) end)
    case result do
      [] -> nil
      [head|_] -> head["short_name"]
      _ -> "error in get_item"
    end
  end
end
