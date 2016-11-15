defmodule Locorum.Repo.Migrations.AddBackendsDownToResultCollection do
  use Ecto.Migration

  def change do
    alter table(:result_collections) do
      add :backends_down, :string, default: nil
    end
  end
end
