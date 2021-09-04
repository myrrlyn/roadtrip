defmodule Roadtrip.Garage do
  @moduledoc """
  The Garage context.
  """

  import Ecto.Query, warn: false
  alias Roadtrip.Repo
  alias Roadtrip.Garage.{Measurement, Vehicle}

  ##############################################################################

  # Vehicles

  @doc """
  Returns the list of vehicles.
  """
  @spec list_vehicles() :: [%Vehicle{}]
  def list_vehicles(),
    do:
      Vehicle
      # First sort by name, then sort by VIN
      |> order_by(asc_nulls_last: :name, asc: :vin)
      |> Repo.all()

  @doc """
  Gets a single vehicle by database ID.

  Returns `nil` if the provided ID is not present in the database.
  """
  @spec get_vehicle(integer()) :: %Vehicle{} | nil
  def get_vehicle(id), do: Vehicle |> Repo.get(id)

  @doc """
  Gets a single vehicle by database ID.

  Raises `Ecto.NoResultsError` if the `Vehicle` does not exist.
  """
  @spec get_vehicle!(integer()) :: %Vehicle{}
  def get_vehicle!(id), do: Vehicle |> Repo.get!(id)

  @doc """
  Gets a single vehicle by its VIN.

  Returns `nil` if the provided VIN is not present in the database.
  """
  @spec get_vehicle_by_vin(String.t()) :: %Vehicle{} | nil
  def get_vehicle_by_vin(vin) when is_binary(vin),
    do: Vehicle |> Repo.get_by(vin: vin)

  @doc """
  Gets a single vehicle by its VIN.

  Raises `Ecto.NoResultsError` if the `Vehicle` does not exist.
  """
  @spec get_vehicle_by_vin!(String.t()) :: %Vehicle{}
  def get_vehicle_by_vin!(vin) when is_binary(vin),
    do: Vehicle |> Repo.get_by!(vin: vin)

  @doc """
  Creates a vehicle record in the database.
  """
  def create_vehicle(attrs \\ %{}) do
    %Vehicle{}
    |> change_vehicle(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vehicle record in the database.
  """
  def update_vehicle(%Vehicle{} = vehicle, attrs) do
    vehicle
    |> change_vehicle(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vehicle, and all of its measurements, from the database.
  """
  def delete_vehicle(%Vehicle{} = vehicle), do: vehicle |> delete_measurements() |> Repo.delete()

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle changes.
  """
  def change_vehicle(%Vehicle{} = vehicle, attrs \\ %{}), do: vehicle |> Vehicle.changeset(attrs)

  ##############################################################################

  # Vehicle measurements

  @doc """
  Returns the list of all measurements.
  """
  @spec list_measurements() :: [%Measurement{}]
  def list_measurements() do
    Measurement
    |> order_by(asc: :vehicle_id, asc: :odometer, asc: :moment)
    |> Repo.all()
  end

  @doc """
  Returns the list of measurements for a given `Vehicle`.
  """
  @spec list_measurements(%Vehicle{}) :: [%Measurement{}]
  def list_measurements(%Vehicle{} = vehicle) do
    vehicle
    |> query_measurements()
    |> Repo.all()
  end

  def query_measurements(%Vehicle{id: vid}) do
    Measurement |> where(vehicle_id: ^vid) |> order_by(asc: :odometer, asc: :moment)
  end

  @doc """
  Gets a single measurement.

  Raises `Ecto.NoResultsError` if the Measurement does not exist.
  """
  @spec get_measurement!(integer()) :: %Measurement{}
  def get_measurement!(id), do: Measurement |> Repo.get!(id)

  @spec get_measurement!(%Vehicle{}, DateTime.t()) :: %Measurement{}
  def get_measurement!(%Vehicle{} = vehicle, moment) do
    vehicle |> query_measurements() |> Repo.get_by!(moment: moment)
  end

  @doc """
  Creates a measurement.
  """
  def create_measurement(attrs \\ %{}) do
    %Measurement{}
    |> Measurement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a measurement.
  """
  def update_measurement(%Measurement{} = measurement, attrs) do
    measurement
    |> Measurement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a measurement.
  """
  def delete_measurement(%Measurement{} = measurement), do: measurement |> Repo.delete()

  @doc """
  Deletes all measurements associated with a `Vehicle`.
  """
  def delete_measurements(%Vehicle{id: vid} = vehicle) do
    Measurement |> where(vehicle_id: ^vid) |> Repo.delete_all()
    vehicle
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking measurement changes.
  """
  def change_measurement(%Measurement{} = measurement, attrs \\ %{}),
    do: measurement |> Measurement.changeset(attrs)
end
