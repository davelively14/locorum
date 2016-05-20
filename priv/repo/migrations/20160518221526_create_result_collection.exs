defmodule Locorum.Repo.Migrations.CreateResultCollection do
  use Ecto.Migration

  def change do
    create table(:result_collections) do
      add :search_id, references(:searches)

      timestamps
    end
  end
end
