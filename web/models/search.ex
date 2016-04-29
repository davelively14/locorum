defmodule Locorum.Search do
  use Locorum.Web, :model

  schema "searches" do
    field :name, :string
    field :biz, :string
    field :address1, :string
    field :address2, :string, virtual: true
    field :city, :string
    field :state, :string
    field :zip, :string
    field :phone, :string
    belongs_to :project, Locorum.Project
    belongs_to :user, Locorum.User

    timestamps
  end

  @required_fields ~w(biz zip city state address1 phone user_id)
  @optional_fields ~w(name address2 project_id)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> format_phone
    |> validate_length(:address1, min: 4, max: 50)
    |> validate_length(:state, min: 2, max: 2)
    |> validate_length(:zip, min: 5, max: 5)
    # TODO change message. If too short, ask for area code. If too long, prompt to drop country code
    |> validate_length(:phone, min: 10, max: 11)
  end

  defp format_phone(changeset) do
    if phone = get_change(changeset, :phone) do
      put_change(changeset, :phone, phonify(phone))
    else
      changeset
    end
  end

  defp phonify(string), do: String.replace(string, ~r/[^\w]/, "")
end
