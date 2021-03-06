defmodule Roadtrip.Garage do
  @moduledoc """
  The Garage context.

  This contains general functions for working with Vehicle and Measurement
  records.
  """

  import Ecto.Query, warn: false
  alias Roadtrip.Repo
  alias Roadtrip.Garage.{Measurement, Vehicle, Refuel}

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
  @spec create_vehicle(%{(String.t() | atom()) => any()}) ::
          {:ok, %Vehicle{}} | {:error, Ecto.Changeset.t()}
  def create_vehicle(attrs \\ %{}) do
    %Vehicle{}
    |> change_vehicle(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vehicle record in the database.
  """
  @spec update_vehicle(%Vehicle{}, %{(String.t() | any()) => any()}) ::
          {:ok, %Vehicle{}} | {:error, Ecto.Changeset.t()}
  def update_vehicle(%Vehicle{} = vehicle, attrs) do
    vehicle
    |> change_vehicle(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vehicle, and all of its measurements, from the database.
  """
  @spec delete_vehicle(%Vehicle{}) :: {:ok, %Vehicle{}} | {:error, Ecto.Changeset.t()}
  def delete_vehicle(%Vehicle{} = vehicle), do: vehicle |> delete_measurements() |> Repo.delete()

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle changes.
  """
  @spec change_vehicle(%Vehicle{}) :: Ecto.Changeset.t()
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

  @doc """
  Creates a database query for all Measurements associated with a Vehicle.
  """
  @spec query_measurements(%Vehicle{}) :: Ecto.Query.t()
  def query_measurements(%Vehicle{id: vid}) do
    Measurement |> where(vehicle_id: ^vid) |> order_by(asc: :odometer, asc: :moment)
  end

  @doc """
  Gets a single measurement.

  Raises `Ecto.NoResultsError` if the Measurement does not exist.
  """
  @spec get_measurement!(integer()) :: %Measurement{}
  def get_measurement!(id), do: Measurement |> Repo.get!(id)

  @doc """
  Gets the measurement for a given `Vehicle` and moment.

  Raises `Ecto.NoResultsError` if the Measurement does not exist.
  """
  @spec get_measurement!(%Vehicle{}, DateTime.t()) :: %Measurement{}
  def get_measurement!(%Vehicle{} = vehicle, moment) do
    vehicle |> query_measurements() |> Repo.get_by!(moment: moment)
  end

  @doc """
  Creates a measurement.

  ## Parameters

  - `vehicle`: A `Vehicle` record to which the created `Measurement` will be
    attached. It must be persisted in the database and possess a database ID.
  """
  @spec create_measurement(%Vehicle{}, %{(String.t() | atom()) => any()}) ::
          {:ok, %Measurement{}} | {:error, Ecto.Changeset.t()}
  def create_measurement(%Vehicle{} = vehicle, attrs \\ %{}) do
    vehicle
    |> Ecto.build_assoc(:measurements)
    |> Measurement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Insert many objects into the database at once.

  This uses `Ecto.Repo.insert_all/2`, which does *not* operate on
  `Ecto.Changeset` structures. As such, this takes an `Enumerable` that yields
  maps with attributes `%{moment: DateTimet.(), odometer: integer()}`, instead
  of a well-formed `Changeset` produced by `change_measurement/2`.

  ## Parameters

  - any `Enumerable` that yields `%{moment: DateTime.t(), odometer: integer()}`
  - the `Vehicle` record that owns the batch of measurements
  """
  @spec batch_create_measurements(Enumerable.t(), %Vehicle{}) ::
          {integer(), [%Measurement{}] | nil}
  def batch_create_measurements(seq, %Vehicle{id: vid}) do
    now = DateTime.utc_now() |> DateTime.to_naive()

    seq =
      seq
      |> Stream.map(
        &(&1
          |> Map.put(:vehicle_id, vid)
          |> Map.put(:created_at, now)
          |> Map.put(:updated_at, now))
      )
      |> Enum.to_list()

    Measurement |> Repo.insert_all(seq)
  end

  @doc """
  Updates a measurement.
  """
  @spec update_measurement(%Measurement{}, %{(String.t() | atom()) => any()}) ::
          {:ok, %Measurement{}} | {:error, Ecto.Changeset.t()}
  def update_measurement(%Measurement{} = measurement, attrs) do
    measurement
    |> Measurement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a measurement.
  """
  @spec delete_measurement(%Measurement{}) :: {:ok, %Measurement{}}
  def delete_measurement(%Measurement{} = measurement), do: measurement |> Repo.delete()

  @doc """
  Deletes all measurements associated with a `Vehicle`.
  """
  @spec delete_measurements(%Vehicle{}) :: %Vehicle{}
  def delete_measurements(%Vehicle{id: vid} = vehicle) do
    Measurement |> where(vehicle_id: ^vid) |> Repo.delete_all()
    vehicle
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking measurement changes.
  """
  @spec change_measurement(%Measurement{}, %{(String.t() | atom()) => any()}) ::
          Ecto.Changeset.t()
  def change_measurement(%Measurement{} = measurement, attrs \\ %{}),
    do: measurement |> Measurement.changeset(attrs)

  ##############################################################################

  # Refuel events

  @doc """
  Queries the database for only Measurements that have an associated refuel.

  ## Parameters

  ## Returns

  A database query that will, when executed, look up only the refueling
  mesaruements for the given vehicle.
  """
  def refuels(%Vehicle{} = vehicle), do:
    vehicle
    |> query_measurements()
    |> where([m], fragment("? IS NOT NULL", m.price) and fragment("? IS NOT NULL", m.volume))

  @doc """
  Sums the Refuel events in a list of Measurements.

  ## Returns

  A tuple of `{total_volume, total_cost}`.
  """
  @spec refuel_sum(Enumerable.t()) :: {Decimal.t(), Decimal.t()}
  def refuel_sum(measurements) do
    measurements
    |> Stream.map(&Measurement.refuel/1)
    |> Stream.reject(&is_nil/1)
    |> Stream.map(fn %Refuel{volume: volume} = refuel ->
      {volume, refuel |> Refuel.total_cost()}
    end)
    |> Enum.reduce({Decimal.new(0), Decimal.new(0)}, fn {vol, cost}, {accum_v, accum_c} ->
      {Decimal.add(vol, accum_v), Decimal.add(cost, accum_c)}
    end)
  end
end
