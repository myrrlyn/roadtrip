defmodule RoadtripWeb.MeasurementControllerTest do
  use RoadtripWeb.ConnCase

  import Roadtrip.GarageFixtures

  alias Roadtrip.Garage.Measurement

  @create_attrs %{moment: ~U[2021-09-02 15:18:00Z], odometer: 42, vehicle_id: nil}
  @update_attrs %{moment: ~U[2021-09-03 15:18:00Z], odometer: 43, vehicle_id: nil}
  @invalid_attrs %{moment: nil, odometer: nil, vehicle_id: nil}

  describe "index" do
    setup [:create_vehicle]

    test "lists all measurements", %{conn: conn, vehicle: vehicle} do
      conn = get(conn, Routes.vehicle_measurement_path(conn, :index, vehicle))
      assert html_response(conn, 200) =~ "Listing Measurements"
    end
  end

  describe "new measurement" do
    setup [:create_vehicle]

    test "renders form", %{conn: conn, vehicle: vehicle} do
      conn = get(conn, Routes.vehicle_measurement_path(conn, :new, vehicle))
      assert html_response(conn, 200) =~ "New Measurement"
      assert html_response(conn, 200) =~ vehicle |> Roadtrip.Garage.Vehicle.show_name()
    end
  end

  describe "create measurement" do
    setup [:create_vehicle]

    test "redirects to show when data is valid", %{conn: conn, vehicle: vehicle} do
      conn =
        post(conn, Routes.vehicle_measurement_path(conn, :create, vehicle),
          measurement: %{@create_attrs | vehicle_id: vehicle.id}
        )

      assert %{moment: moment} = redirected_params(conn)
      assert redirected_to(conn) == Routes.vehicle_measurement_path(conn, :show, vehicle, moment)

      conn = get(conn, Routes.vehicle_measurement_path(conn, :show, vehicle, moment))
      assert html_response(conn, 200) =~ "Show Measurement"
    end

    test "renders errors when data is invalid", %{conn: conn, vehicle: vehicle} do
      conn =
        post(conn, Routes.vehicle_measurement_path(conn, :create, vehicle),
          measurement: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Measurement"
    end
  end

  describe "edit measurement" do
    setup [:create_vehicle, :create_measurement]

    test "renders form for editing chosen measurement", %{
      conn: conn,
      measurement: measurement,
      vehicle: vehicle
    } do
      conn = get(conn, Routes.vehicle_measurement_path(conn, :edit, vehicle, measurement))
      assert html_response(conn, 200) =~ "Edit Measurement"
    end
  end

  describe "update measurement" do
    setup [:create_vehicle, :create_measurement]

    test "redirects when data is valid", %{conn: conn, measurement: measurement, vehicle: vehicle} do
      conn =
        put(conn, Routes.vehicle_measurement_path(conn, :update, vehicle, measurement),
          measurement: %{@update_attrs | vehicle_id: vehicle.id}
        )

      updated = %Measurement{measurement | moment: @update_attrs[:moment]}

      assert redirected_to(conn) ==
               Routes.vehicle_measurement_path(conn, :show, vehicle, updated)

      conn = get(conn, Routes.vehicle_measurement_path(conn, :show, vehicle, updated))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      measurement: measurement,
      vehicle: vehicle
    } do
      conn =
        put(conn, Routes.vehicle_measurement_path(conn, :update, vehicle, measurement),
          measurement: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Measurement"
    end
  end

  describe "delete measurement" do
    setup [:create_vehicle, :create_measurement]

    test "deletes chosen measurement", %{conn: conn, measurement: measurement, vehicle: vehicle} do
      conn = delete(conn, Routes.vehicle_measurement_path(conn, :delete, vehicle, measurement))
      assert redirected_to(conn) == Routes.vehicle_measurement_path(conn, :index, vehicle)

      assert_error_sent 404, fn ->
        get(conn, Routes.vehicle_measurement_path(conn, :show, vehicle, measurement))
      end
    end
  end

  defp create_vehicle(_) do
    vehicle = vehicle_fixture()
    %{vehicle: vehicle}
  end

  defp create_measurement(%{vehicle: vehicle}) do
    measurement = measurement_fixture(vehicle_id: vehicle.id)
    %{measurement: measurement}
  end
end
