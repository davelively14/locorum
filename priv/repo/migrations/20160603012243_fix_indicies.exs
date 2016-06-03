defmodule Locorum.Repo.Migrations.FixIndicies do
  use Ecto.Migration

  def change do
    create index(:result_collections, [:search_id])
    create index(:results, [:result_collection_id])
  end
end
