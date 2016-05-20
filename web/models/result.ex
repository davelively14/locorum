defmodule Locorum.Result do
  use Locorum.Web, :model

  schema "results" do
    field :name, :string
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :phone, :string
    field :rating, :string
    field :url, :string
    belongs_to :result_collection, Locorum.ResultCollection
    belongs_to :backend, Locorum.Backend

    timestamps
  end

  @required_fields ~w(name address city state phone rating url)
  @optional_fields ~w(zip)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
