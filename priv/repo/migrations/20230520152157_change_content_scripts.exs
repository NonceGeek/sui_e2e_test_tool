defmodule MoveE2eTestTool.Repo.Migrations.ChangeContentScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      modify :content, :text
    end
  end
end
