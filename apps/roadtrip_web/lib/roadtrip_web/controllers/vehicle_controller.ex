defmodule RoadtripWeb.VehicleController do
  use RoadtripWeb, :controller

  alias Roadtrip.Garage
  alias Roadtrip.Garage.Vehicle

  def index(conn, _params) do
    vehicles = Garage.list_vehicles()
    render(conn, "index.html", vehicles: vehicles)
  end

  def new(conn, _params) do
    changeset = Garage.change_vehicle(%Vehicle{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"vehicle" => vehicle_params}) do
    case Garage.create_vehicle(vehicle_params) do
      {:ok, vehicle} ->
        conn
        |> put_flash(:info, "Vehicle created successfully.")
        |> redirect(to: Routes.vehicle_path(conn, :show, vehicle))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"vin" => vin}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)
    render(conn, "show.html", vehicle: vehicle)
  end

  def edit(conn, %{"vin" => vin}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)
    changeset = Garage.change_vehicle(vehicle)
    render(conn, "edit.html", vehicle: vehicle, changeset: changeset)
  end

  def update(conn, %{"vin" => vin, "vehicle" => vehicle_params}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)

    case Garage.update_vehicle(vehicle, vehicle_params) do
      {:ok, vehicle} ->
        conn
        |> put_flash(:info, "Vehicle updated successfully.")
        |> redirect(to: Routes.vehicle_path(conn, :show, vehicle))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", vehicle: vehicle, changeset: changeset)
    end
  end

  def delete(conn, %{"vin" => vin}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)
    {:ok, _vehicle} = Garage.delete_vehicle(vehicle)

    conn
    |> put_flash(:info, "Vehicle deleted successfully.")
    |> redirect(to: Routes.vehicle_path(conn, :index))
  end
end

# The web API accesses vehicles by VIN, not by database ID.
defimpl Phoenix.Param, for: Roadtrip.Garage.Vehicle do
  def to_param(%Roadtrip.Garage.Vehicle{vin: vin}), do: vin
end
