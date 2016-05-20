defmodule Locorum.Repo.Migrations.ResultPointsToResultCollection do
  use Ecto.Migration

  def change do
    alter table(:results) do
      remove :ignored
      remove :search_id
      add :result_collection_id, references(:result_collections)
    end
  end
end
