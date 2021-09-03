defmodule Roadtrip.GarageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Roadtrip.Garage` context.
  """

  @doc """
  Generate a unique vehicle vin.
  """
  def unique_vin() do
    seq =
      System.unique_integer([:positive, :monotonic]) |> to_string() |> String.pad_leading(6, "0")

    pfx = "1G3WH52M0VF"
    (pfx <> seq) |> Roadtrip.Garage.Vin.write_na_checksum()
  end

  @doc """
  Generate a vehicle.
  """
  def vehicle_fixture(attrs \\ %{}) do
    {:ok, vehicle} =
      attrs
      |> Enum.into(%{
        make: "Oldsmobile",
        model: "Cutlass",
        name: "Test Chassis",
        vin: unique_vin(),
        year: 1997
      })
      |> Roadtrip.Garage.create_vehicle()

    vehicle
  end
end
