defmodule Locorum.CSVController do
  use Locorum.Web, :controller
  alias Locorum.Repo
  alias Locorum.Search

  plug :scrub_params, "upload" when action in [:create]

  def create(conn, %{"upload" => %{"csv" => csv, "project_id" => project_id, "user_id" => user_id}}) do
    searches =
      case File.read(csv.path) do
        {:ok, result} ->
          result =
            result
            |> String.split("\n")
            |> Locorum.BackendSys.Helpers.pop_first(1)
            |> split_results
            |> add_to_search([project_id, user_id])
        _ ->
          {:error, "Invalid file type"}
      end
    Enum.each searches, fn search ->
      changeset = Search.changeset(%Search{}, Map.from_struct(search))
      case Repo.insert(changeset) do
        {:ok, search} ->
          conn = put_flash(conn, :info, "Added some searches")
        {:error, changeset} ->
          conn = put_flash(conn, :error, "Some searches could not be added from CSV")
      end
    end
    conn
    # TODO why isn't flash working?
    |> redirect(to: project_path(conn, :show, project_id))
    # render conn, "new.html", searches: searches, project: project, user: user
  end

  def split_results([]), do: []
  def split_results([head|tail]), do: [String.split(head, ",")|split_results(tail)]

  # def join_results(keys, values), do: join_results(keys, values, %{})
  # def join_results([], [], acc), do: acc
  # def join_results([], _, _acc), do: {:error, "Values longer than keys"}
  # def join_results(_, [], _acc), do: {:error, "Keys longer than values"}
  # def join_results([keys_head|keys_tail], [values_head|values_tail], acc) do
  #   join_results(keys_tail, values_tail, Map.put(acc, keys_head, values_head))
  # end
  #
  # def get_size(list), do: get_size(list, 0)
  # def get_size([], acc), do: acc
  # def get_size([_head|tail], acc), do: get_size(tail, acc + 1)

  def add_to_search([], _), do: []
  def add_to_search([head|tail], [project_id, user_id]) do
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
end
