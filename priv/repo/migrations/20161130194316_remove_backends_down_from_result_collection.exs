defmodule Locorum.Repo.Migrations.RemoveBackendsDownFromResultCollection do
  use Ecto.Migration

  def change do
    alter table(:result_collections) do
      remove :backends_down
    end
  end
end
