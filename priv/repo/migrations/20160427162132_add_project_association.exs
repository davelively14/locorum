defmodule Locorum.Repo.Migrations.AddProjectAssociation do
  use Ecto.Migration

  def change do
    alter table(:searches) do
      add :project_id, references(:projects)
    end

    create index(:searches, [:project_id])
  end
end
