defmodule :"Elixir.Roadtrip.Repo.Migrations.ShorterStrings" do
  use Ecto.Migration

  def change do
    alter table(:vehicles) do
      modify :vin, :string, from: :string, size: 17, null: false
      modify :name, :string, from: :string, size: 32, null: true
      modify :make, :string, from: :string, size: 32, null: false
      modify :model, :string, from: :string, size: 32, null: false
    end
  end
end
