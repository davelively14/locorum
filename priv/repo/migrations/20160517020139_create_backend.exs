defmodule Locorum.Repo.Migrations.CreateBackend do
  use Ecto.Migration

  def change do
    create table(:backends) do
      add :module, :string
      add :name, :string
      add :name_str, :string
      add :url, :string

      timestamps
    end

    create unique_index(:backends, [:module])
  end
end
