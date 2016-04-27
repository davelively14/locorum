defmodule Locorum.Repo.Migrations.AddUserIdToSearch do
  use Ecto.Migration

  def change do
    alter table(:searches) do
      add :user_id, references(:users)
    end

    create index(:searches, [:user_id])
  end
end
