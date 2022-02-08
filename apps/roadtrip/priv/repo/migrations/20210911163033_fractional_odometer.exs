defmodule Roadtrip.Repo.Migrations.FractionalOdometer do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      modify :odometer, :decimal, from: :integer
    end
  end
end
