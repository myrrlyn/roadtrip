defmodule Roadtrip.Repo.Migrations.CreateVehicles do
  use Ecto.Migration

  def change do
    create table(:vehicles) do
      add :name, :string
      add :make, :string
      add :model, :string
      add :year, :integer
      add :vin, :string

      timestamps()
    end

    create unique_index(:vehicles, [:vin])
  end
end
