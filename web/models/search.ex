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

  @required_fields ~w(biz zip)
  @optional_fields ~w(name address1 address2 city state)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
