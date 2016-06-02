defmodule Locorum.Repo.Migrations.ChangeUrlToText do
  use Ecto.Migration

  def change do
    alter table(:results) do
      modify :url, :text
    end
  end
end
