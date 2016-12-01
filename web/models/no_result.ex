defmodule Locorum.NoResult do
  use Locorum.Web, :model

  schema "no_results" do
    field :reason, :string
    belongs_to :result_collection, Locorum.ResultCollection
    belongs_to :backend, Locorum.Backend

    timestamps
  end

  @required_fields ~w(reason)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
