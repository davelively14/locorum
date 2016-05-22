defmodule Locorum.Backend do
  use Locorum.Web, :model

  schema "backends" do
    field :module, :string
    field :name, :string
    field :name_str, :string
    field :url, :string
    has_many :results, Locorum.Result

    timestamps
  end

  @required_params ~w(module name name_str url)
  @optional_params ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_params, @optional_params)
    |> unique_constraint(:name)
    |> unique_constraint(:module)
    |> validate_length(:module, min: 5, max: 100)
    |> validate_length(:name, min: 1, max: 50)
    |> validate_length(:name_str, min: 1, max: 50)
    |> validate_length(:url, min: 7, max: 80)
  end
end
