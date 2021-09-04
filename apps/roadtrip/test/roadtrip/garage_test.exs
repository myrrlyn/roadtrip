defmodule Roadtrip.GarageTest do
  use Roadtrip.DataCase

  alias Roadtrip.{Garage, Repo}

  describe "vehicles" do
    alias Roadtrip.Garage.Vehicle

    import Roadtrip.GarageFixtures

    setup [:create_vehicle]

    @invalid_attrs %{make: nil, model: nil, name: nil, vin: nil, year: nil}

    test "list_vehicles/0 returns all vehicles", %{vehicle: vehicle} do
      assert Garage.list_vehicles() == [vehicle]
    end

    test "get_vehicle!/1 returns the vehicle with given id", %{vehicle: vehicle} do
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

    test "update_vehicle/2 with valid data updates the vehicle", %{vehicle: vehicle} do
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

    test "update_vehicle/2 with invalid data returns error changeset", %{vehicle: vehicle} do
      assert {:error, %Ecto.Changeset{}} = Garage.update_vehicle(vehicle, @invalid_attrs)
      assert vehicle == Garage.get_vehicle!(vehicle.id)
    end

    test "delete_vehicle/1 deletes the vehicle", %{vehicle: vehicle} do
      assert {:ok, %Vehicle{}} = Garage.delete_vehicle(vehicle)
      assert_raise Ecto.NoResultsError, fn -> Garage.get_vehicle!(vehicle.id) end
    end

    test "change_vehicle/1 returns a vehicle changeset", %{vehicle: vehicle} do
      assert %Ecto.Changeset{} = Garage.change_vehicle(vehicle)
    end
  end

  describe "measurements" do
    alias Roadtrip.Garage.Measurement

    import Roadtrip.GarageFixtures

    setup [:create_vehicle]

    @invalid_attrs %{moment: nil, odometer: nil, vehicle_id: nil}

    test "list_measurements/0 returns all measurements", %{vehicle: vehicle} do
      measurement = measurement_fixture(vehicle_id: vehicle.id)
      assert Garage.list_measurements() == [measurement]
      assert Garage.list_measurements(vehicle) == [measurement]
    end

    test "get_measurement!/1 returns the measurement with given id", %{vehicle: vehicle} do
      measurement = measurement_fixture(vehicle_id: vehicle.id)
      assert Garage.get_measurement!(measurement.id) == measurement
    end

    test "create_measurement/1 with valid data creates a measurement", %{vehicle: vehicle} do
      valid_attrs = %{moment: ~U[2021-09-02 15:18:00Z], odometer: 42, vehicle_id: vehicle.id}

      assert {:ok, %Measurement{} = measurement} = Garage.create_measurement(valid_attrs)

      measurement = Repo.preload(measurement, :vehicle)

      assert measurement.moment == ~U[2021-09-02 15:18:00Z]
      assert measurement.odometer == 42
      assert measurement.vehicle == vehicle
    end

    test "create_measurement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Garage.create_measurement(@invalid_attrs)
    end

    test "update_measurement/2 with valid data updates the measurement", %{vehicle: vehicle} do
      measurement = measurement_fixture(vehicle_id: vehicle.id)
      update_attrs = %{moment: ~U[2021-09-03 15:18:00Z], odometer: 43, vehicle_id: vehicle.id}

      assert {:ok, %Measurement{} = measurement} =
               Garage.update_measurement(measurement, update_attrs)

      assert measurement.moment == ~U[2021-09-03 15:18:00Z]
      assert measurement.odometer == 43
    end

    test "update_measurement/2 with invalid data returns error changeset", %{vehicle: vehicle} do
      measurement = measurement_fixture(vehicle_id: vehicle.id)

      assert {:error, %Ecto.Changeset{}} =
               Garage.update_measurement(measurement, %{@invalid_attrs | vehicle_id: vehicle.id})

      assert measurement == Garage.get_measurement!(measurement.id)
    end

    test "delete_measurement/1 deletes the measurement", %{vehicle: vehicle} do
      measurement = measurement_fixture(vehicle_id: vehicle.id)
      assert {:ok, %Measurement{}} = Garage.delete_measurement(measurement)
      assert_raise Ecto.NoResultsError, fn -> Garage.get_measurement!(measurement.id) end
    end

    test "change_measurement/1 returns a measurement changeset", %{vehicle: vehicle} do
      measurement = measurement_fixture(vehicle_id: vehicle.id)
      assert %Ecto.Changeset{} = Garage.change_measurement(measurement)
    end
  end

  defp create_vehicle(_), do: %{vehicle: Roadtrip.GarageFixtures.vehicle_fixture()}
end
