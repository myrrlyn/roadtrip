defmodule Roadtrip.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :odometer, :integer, null: false
      add :moment, :utc_datetime, null: false
      add :vehicle_id, references(:vehicles, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:measurements, [:vehicle_id])
  end
end
