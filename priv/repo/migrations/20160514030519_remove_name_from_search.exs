defmodule Locorum.Repo.Migrations.RemoveNameFromSearch do
  use Ecto.Migration

  def change do
    alter table(:searches) do
      remove :name
    end
  end
end
