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
    field :ignored, :boolean, default: false
    belongs_to :search, Locorum.Search
    belongs_to :backend, Locorum.Backend

    timestamps
  end
end

defstruct biz: nil, address: nil, city: nil, state: nil, zip: nil,
          rating: nil, url: nil, phone: nil
