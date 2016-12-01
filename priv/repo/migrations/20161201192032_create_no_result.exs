defmodule Locorum.Repo.Migrations.CreateNoResult do
  use Ecto.Migration

  def change do
    create table(:no_results) do
      add :reason, :string
      add :result_collection_id, references(:result_collections)
      add :backend_id, references(:backends)

      timestamps
    end

    create index(:no_results, [:result_collection_id])
    create index(:no_results, [:backend_id])
  end
end
