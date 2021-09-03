defmodule Roadtrip.Garage.Vehicle do
  @moduledoc """
  Describes a vehicle registered in the system.

  Vehicles are the base unit of record-keeping in Roadtrip: they own, and give
  context to, a series of odometer, fuel, and maintenance measurements.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :make, :string
    field :model, :string
    field :name, :string
    field :vin, :string
    field :year, :integer

    timestamps()
  end

  @doc false
  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:name, :make, :model, :year, :vin])
    # Names are optional
    |> validate_required([:make, :model, :year, :vin])
    # Constrain the vehicle year to be between 1954 (creation of the North
    # American VIN) and now.
    |> validate_number(:year,
      greater_than_or_equal_to: 1954,
      less_than_or_equal_to: DateTime.utc_now().year
    )
    # Uppercase the VIN
    |> update_change(:vin, &String.upcase/1)
    # Validate the VIN’s length, alphabet, and checksum.
    |> validate_change(:vin, fn :vin, vin ->
      case Roadtrip.Garage.Vin.na_checksum(vin) do
        {:ok, _} -> []
        # Enforce North American checksumming for now
        {:warn, warn} -> [vin: warn]
        {:error, err} -> [vin: err]
      end
    end)
    # VINs are unique in the system and, ideally, the real world.
    |> unique_constraint(:vin, message: "This VIN has already been registered in the system")
  end

  @doc """
  Renders a name for a vehicle. When the vehicle is named, this uses its name;
  when it is unnamed, it uses its make/model/year as produced by `describe/1`.
  """
  @spec show_name(%__MODULE__{}) :: String.t()
  def show_name(%__MODULE__{name: name} = vehicle) do
    case name do
      "" -> vehicle |> describe()
      nil -> vehicle |> describe()
      name -> name |> to_string()
    end
  end

  @doc """
  Describes a vehicle by make, model, and year.
  """
  @spec describe(%__MODULE__{}) :: String.t()
  def describe(%__MODULE__{make: make, model: model, year: year}),
    do: "#{make} #{model} (#{year})"
end
