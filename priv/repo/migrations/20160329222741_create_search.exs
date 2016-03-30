defmodule Locorum.Repo.Migrations.CreateSearch do
  use Ecto.Migration

  def change do
    create table(:searches) do
      add :name, :string
      add :biz, :string
      add :address1, :string
      add :address2, :string
      add :city, :string
      add :state, :string
      add :zip, :string

      timestamps
    end
  end
end
