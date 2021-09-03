defmodule Roadtrip.Garage do
  @moduledoc """
  The Garage context.
  """

  import Ecto.Query, warn: false
  alias Roadtrip.Repo
  alias Roadtrip.Garage.Vehicle

  @doc """
  Returns the list of vehicles.
  """
  @spec list_vehicles() :: [%Vehicle{}]
  def list_vehicles(), do: Vehicle |> Repo.all()

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
  def get_vehicle_by_vin(vin) when is_binary(vin), do: Vehicle |> Repo.get_by(vin: vin)

  @doc """
  Gets a single vehicle by its VIN.

  Raises `Ecto.NoResultsError` if the `Vehicle` does not exist.
  """
  @spec get_vehicle_by_vin!(String.t()) :: %Vehicle{}
  def get_vehicle_by_vin!(vin) when is_binary(vin), do: Vehicle |> Repo.get_by!(vin: vin)

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
  Deletes a vehicle from the database.
  """
  def delete_vehicle(%Vehicle{} = vehicle), do: vehicle |> Repo.delete()

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vehicle changes.
  """
  def change_vehicle(%Vehicle{} = vehicle, attrs \\ %{}), do: vehicle |> Vehicle.changeset(attrs)
end
