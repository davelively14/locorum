defmodule Locorum.Project do
  use Locorum.Web, :model

  schema "projects" do
    field :name, :string
    has_many :searches, Locorum.Search

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:name, min: 1, max: 30)
  end
end
