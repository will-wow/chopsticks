defmodule Chopsticks.Repo.Migrations.CreateMove do
  use Ecto.Migration

  def change do
    create table(:moves) do
      add :left, :integer
      add :right, :integer

      timestamps()
    end

  end
end
