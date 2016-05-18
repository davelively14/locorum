defmodule Locorum.Repo.Migrations.AddUniqueIndexForNameToBackend do
  use Ecto.Migration

  def change do
    create unique_index(:backends, [:name])
  end
end
