defmodule Locorum.Search do
  use Locorum.Web, :model

  schema "searches" do
    field :name, :string
    field :biz, :string
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :state, :string
    field :zip, :string

    timestamps
  end

  @required_fields ~w(biz zip city state)
  @optional_fields ~w(name address1 address2)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:address1, min: 4, max: 50)
    |> validate_length(:address2, min: 4, max: 50)
    |> validate_length(:state, min: 2, max: 2)
    |> validate_length(:zip, min: 5, max: 5)
  end
end
