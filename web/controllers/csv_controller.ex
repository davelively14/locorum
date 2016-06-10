defmodule Locorum.CSVController do
  use Locorum.Web, :controller
  alias Locorum.Repo
  alias Locorum.Search
  alias Locorum.Result

  plug :scrub_params, "upload" when action in [:create, :update]

  def create(conn, %{"upload" => %{"csv" => csv, "project_id" => project_id, "user_id" => user_id}}) do
    searches =
      case File.read(csv.path) do
        {:ok, result} ->
          result =
            result
            |> String.split("\n")
            # TODO move this helper to somewhere else
            |> Locorum.BackendSys.Helpers.pop_first(1)
            |> split_results
            |> add_to_search([project_id, user_id])
        _ ->
          {:error, "Invalid file type"}
      end
    Enum.each searches, fn search ->
      changeset = Search.changeset(%Search{}, Map.from_struct(search))
      case Repo.insert(changeset) do
        {:ok, _} ->
          conn = put_flash(conn, :info, "Added some searches")
        {:error, _changeset} ->
          _conn = put_flash(conn, :error, "Some searches could not be added from CSV")
      end
    end
    conn
    |> redirect(to: project_path(conn, :show, project_id))
    # render conn, "new.html", searches: searches, project: project, user: user
  end

  def export(conn, %{"collection_ids" => collection_ids}) do
    collection_ids = String.split(collection_ids, ",")
    results = Repo.all from r in Result,
                       where: r.result_collection_id in ^collection_ids,
                       preload: [:backend]
    results_json = Phoenix.View.render_many(results, Locorum.ResultsView, "result.json")

    header =
      results_json
      |> List.first
      |> Map.keys
      |> Enum.map(&Atom.to_string(&1))
      |> encode_header

    body =
      results_json
      |> Enum.map(&Map.values(&1))
      |> encode_body

    resp = header <> body

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("Content-Disposition", "attachment; filename=\"results.csv\"")
    |> send_resp(200, resp)
  end

  defp split_results([]), do: []
  defp split_results([head|tail]), do: [String.split(head, ",")|split_results(tail)]

  defp add_to_search([], _), do: []
  defp add_to_search([head|tail], [project_id, user_id]) do
    biz = Enum.at(head, 1)
    address1 =
      case Enum.at(head, 3) do
        "" -> Enum.at(head, 2)
        _ -> "#{Enum.at(head, 2)}, #{Enum.at(head, 3)}"
      end
    city = Enum.at(head, 4)
    state = Enum.at(head, 6)
    zip = Enum.at(head, 8)
    phone = Enum.at(head, 9)
    [%Locorum.Search{biz: biz, address1: address1, city: city, state: state,
                     zip: zip, phone: phone, project_id: project_id,
                     user_id: user_id}|add_to_search(tail, [project_id, user_id])]
  end

  def encode_header([]), do: nil
  def encode_header([head|tail]), do: encode_header(tail, "#{head}")
  defp encode_header([], acc), do: "#{acc}\r\n"
  defp encode_header([head|tail], acc), do: encode_header(tail, "#{acc},#{head}")

  def encode_body([]), do: nil
  def encode_body(body), do: encode_body(body, "")
  defp encode_body([], acc), do: acc
  defp encode_body([[head_line|tail_line]|tail], acc), do: encode_body(tail, encode_line(tail_line, "#{acc}\"#{head_line}\""))

  defp encode_line([], acc), do: "#{acc}\r\n"
  defp encode_line([head|tail], acc), do: encode_line(tail, "#{acc},\"#{head}\"")
end
