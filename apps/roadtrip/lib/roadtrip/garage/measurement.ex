defmodule Roadtrip.Garage.Measurement do
  @moduledoc """
  Describes an odometer measurement for a vehicle.

  Measurements are always odometer/timestamp pairs. They may be extended with
  additional information in the future.
  """

  use Roadtrip.Schema
  import Ecto.Changeset
  alias Roadtrip.Garage.Vehicle

  schema "measurements" do
    field :odometer, :integer
    field :moment, :utc_datetime

    belongs_to :vehicle, Vehicle

    timestamps()
  end

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [:odometer, :moment, :vehicle_id])
    |> validate_required([:odometer, :moment, :vehicle_id])
  end
end
