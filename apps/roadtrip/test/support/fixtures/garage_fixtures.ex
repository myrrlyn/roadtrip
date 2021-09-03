defmodule Roadtrip.GarageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Roadtrip.Garage` context.
  """

  @doc """
  Generate a unique vin.

  33 ** 6 is just over 2 ** 30. By the time this overflows, you have other
  problems.
  """
  def unique_vin() do
    seq =
      System.unique_integer([:positive])
      |> Integer.to_string(33)
      |> String.replace(~r/[IOQ]/, fn char ->
        case char do
          "I" -> "X"
          "O" -> "Y"
          "Q" -> "Z"
        end
      end)
      |> String.pad_leading(6, "0")
      |> String.slice(0..5)

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
