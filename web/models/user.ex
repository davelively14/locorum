defmodule Locorum.User do
  use Locorum.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :searches, Locorum.Search

    timestamps
  end

  @required_fields ~w(name username)
  @optional_fields ~w()
end
