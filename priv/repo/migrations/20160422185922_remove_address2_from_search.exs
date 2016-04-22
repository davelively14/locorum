defmodule Locorum.Repo.Migrations.RemoveAddress2FromSearch do
  use Ecto.Migration

  def change do
    alter table(:searches) do
      remove :address2
    end
  end
end
