defmodule Locorum.UserView do
  use Locorum.Web, :view
  alias Locorum.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> List.first
  end

  def last_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> List.last
  end
end
