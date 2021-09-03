defmodule Roadtrip.GarageTest do
  use Roadtrip.DataCase

  alias Roadtrip.Garage

  describe "vehicles" do
    alias Roadtrip.Garage.Vehicle

    import Roadtrip.GarageFixtures

    @invalid_attrs %{make: nil, model: nil, name: nil, vin: nil, year: nil}

    test "list_vehicles/0 returns all vehicles" do
      vehicle = vehicle_fixture()
      assert Garage.list_vehicles() == [vehicle]
    end

    test "get_vehicle!/1 returns the vehicle with given id" do
      vehicle = vehicle_fixture()
      assert Garage.get_vehicle!(vehicle.id) == vehicle
    end

    test "create_vehicle/1 with valid data creates a vehicle" do
      valid_attrs = %{
        make: "Subaru",
        model: "Outback",
        name: "Savah",
        vin: "4S4BSANC6K3352864",
        year: 2019
      }

      assert {:ok, %Vehicle{} = vehicle} = Garage.create_vehicle(valid_attrs)
      assert vehicle.make == "Subaru"
      assert vehicle.model == "Outback"
      assert vehicle.name == "Savah"
      assert vehicle.vin == "4S4BSANC6K3352864"
      assert vehicle.year == 2019
    end

    test "create_vehicle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Garage.create_vehicle(@invalid_attrs)
    end

    test "update_vehicle/2 with valid data updates the vehicle" do
      vehicle = vehicle_fixture()

      update_attrs = %{
        make: "Pontiac",
        model: "Solstice",
        name: "Sybyl",
        vin: "1G2MB35B28Y123226",
        year: 2008
      }

      assert {:ok, %Vehicle{} = vehicle} = Garage.update_vehicle(vehicle, update_attrs)
      assert vehicle.make == "Pontiac"
      assert vehicle.model == "Solstice"
      assert vehicle.name == "Sybyl"
      assert vehicle.vin == "1G2MB35B28Y123226"
      assert vehicle.year == 2008
    end

    test "update_vehicle/2 with invalid data returns error changeset" do
      vehicle = vehicle_fixture()
      assert {:error, %Ecto.Changeset{}} = Garage.update_vehicle(vehicle, @invalid_attrs)
      assert vehicle == Garage.get_vehicle!(vehicle.id)
    end

    test "delete_vehicle/1 deletes the vehicle" do
      vehicle = vehicle_fixture()
      assert {:ok, %Vehicle{}} = Garage.delete_vehicle(vehicle)
      assert_raise Ecto.NoResultsError, fn -> Garage.get_vehicle!(vehicle.id) end
    end

    test "change_vehicle/1 returns a vehicle changeset" do
      vehicle = vehicle_fixture()
      assert %Ecto.Changeset{} = Garage.change_vehicle(vehicle)
    end
  end
end
