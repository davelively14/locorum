defmodule Locorum.CSV do
  use Locorum.Web, :model

  schema "csv" do
    field :name, :string
    field :file, :binary
  end
end
