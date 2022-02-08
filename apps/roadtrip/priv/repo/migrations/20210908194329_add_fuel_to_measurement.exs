defmodule Roadtrip.Repo.Migrations.AddFuelToMeasurement do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      add :price, :decimal
      add :volume, :decimal
    end
  end
end
