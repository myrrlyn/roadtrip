defmodule RoadtripWeb.VehicleControllerTest do
  use RoadtripWeb.ConnCase

  import Roadtrip.GarageFixtures
  alias Roadtrip.Garage.Vehicle

  @create_attrs %{
    make: "Subaru",
    model: "Outback",
    name: "Savah",
    vin: "4S4BSANC6K3352864",
    year: 2019
  }
  @update_attrs %{
    make: "Pontiac",
    model: "Solstice",
    name: "Sybyl",
    vin: "1G2MB35B28Y123226",
    year: 2008
  }
  @invalid_attrs %{make: nil, model: nil, name: nil, vin: nil, year: nil}

  describe "index" do
    test "lists all vehicles", %{conn: conn} do
      conn = get(conn, Routes.vehicle_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Vehicles"
    end
  end

  describe "new vehicle" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.vehicle_path(conn, :new))
      assert html_response(conn, 200) =~ "New Vehicle"
    end
  end

  describe "create vehicle" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.vehicle_path(conn, :create), vehicle: @create_attrs)

      assert %{vin: vin} = redirected_params(conn)
      assert redirected_to(conn) == Routes.vehicle_path(conn, :show, vin)

      conn = get(conn, Routes.vehicle_path(conn, :show, vin))
      assert html_response(conn, 200) =~ "Show Vehicle"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vehicle_path(conn, :create), vehicle: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Vehicle"
    end
  end

  describe "edit vehicle" do
    setup [:create_vehicle]

    test "renders form for editing chosen vehicle", %{conn: conn, vehicle: vehicle} do
      conn = get(conn, Routes.vehicle_path(conn, :edit, vehicle))
      assert html_response(conn, 200) =~ "Edit Vehicle"
    end
  end

  describe "update vehicle" do
    setup [:create_vehicle]

    test "redirects when data is valid", %{conn: conn, vehicle: vehicle} do
      conn = put(conn, Routes.vehicle_path(conn, :update, vehicle), vehicle: @update_attrs)
      updated = %Vehicle{vehicle | vin: @update_attrs[:vin]}

      assert redirected_to(conn) == Routes.vehicle_path(conn, :show, updated)

      conn = get(conn, Routes.vehicle_path(conn, :show, updated))
      assert html_response(conn, 200) =~ "Pontiac"
    end

    test "renders errors when data is invalid", %{conn: conn, vehicle: vehicle} do
      conn = put(conn, Routes.vehicle_path(conn, :update, vehicle), vehicle: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Vehicle"
    end
  end

  describe "delete vehicle" do
    setup [:create_vehicle]

    test "deletes chosen vehicle", %{conn: conn, vehicle: vehicle} do
      conn = delete(conn, Routes.vehicle_path(conn, :delete, vehicle))
      assert redirected_to(conn) == Routes.vehicle_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.vehicle_path(conn, :show, vehicle))
      end
    end
  end

  defp create_vehicle(_) do
    vehicle = vehicle_fixture()
    %{vehicle: vehicle}
  end
end
