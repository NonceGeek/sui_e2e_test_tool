defmodule MoveE2eTestTool.Repo.Migrations.CreateScripts do
  use Ecto.Migration

  def change do
    create table(:scripts) do
      add :name, :string
      add :content, :string

      timestamps()
    end
  end
end
