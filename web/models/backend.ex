defmodule Locorum.Backend do
  use Locorum.Web, :model

  schema "backends" do
    field :name, :string
    field :name_str, :string
    field :url, :string
    has_many :results, Locorum.Result

    timestamps
  end
end
