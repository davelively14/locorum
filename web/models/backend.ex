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
  end
end
