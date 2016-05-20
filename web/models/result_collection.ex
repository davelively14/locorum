defmodule Locorum.ResultCollection do
  use Locorum.Web, :model

  schema "result_collections" do
    belongs_to :search, Locorum.Search
    has_many :results, Locorum.Result

    timestamps
  end

  def changeset(model, params \\ :empty) do
    nil
  end
end
