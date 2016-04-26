defmodule Locorum.Repo.Migrations.AddPhoneToSearch do
  use Ecto.Migration

  def change do
    alter table(:searches) do
      add :phone, :string
    end
  end
end
