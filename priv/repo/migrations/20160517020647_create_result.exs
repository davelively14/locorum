defmodule Locorum.Repo.Migrations.CreateResult do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :name, :string
      add :address, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :phone, :string
      add :rating, :string
      add :url, :string
      add :ignored, :boolean, default: false
      add :search_id, references(:searches)
      add :backend_id, references(:backends)

      timestamps
    end

    create index(:results, [:search_id])
    create index(:results, [:backend_id])
  end
end
