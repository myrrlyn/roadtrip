defmodule Roadtrip.Garage.Measurement do
  @moduledoc """
  Describes an odometer measurement for a vehicle.

  Measurements are always odometer/timestamp pairs. They may be extended with
  additional information in the future.
  """

  use Roadtrip.Schema
  import Ecto.Changeset
  alias Roadtrip.Garage.{Vehicle, Refuel}

  schema "measurements" do
    field :odometer, :decimal
    field :moment, :utc_datetime
    # Refueling is embedded here, but will mostly be nil.
    field :price, :decimal
    field :volume, :decimal

    belongs_to :vehicle, Vehicle

    # These are used to manage the form presented by the web interface.
    # TODO(myrrlyn): Migrate them strictly into RoadtripWeb.
    field :tz, :string, virtual: true
    field :use_refuel, :boolean, virtual: true

    timestamps()
  end

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [:odometer, :moment, :vehicle_id])
    |> cast(attrs, [:price, :volume])
    |> cast(attrs, [:tz, :use_refuel])
    |> validate_required([:odometer, :moment, :vehicle_id])
    |> validate_inclusion(:tz, Tzdata.zone_list(),
      message: "This is not a known timezone identifier"
    )
    |> update_change(:moment, fn moment ->
      try do
        moment
        |> DateTime.to_naive()
        |> DateTime.from_naive!(attrs["tz"])
        |> DateTime.shift_zone!("Etc/UTC")
      rescue
        _ -> moment
      end
    end)
  end

  @doc """
  Gets the `Refuel` structure associated with a `Measurement`.

  `Refuel` is a logical structure that covers the two database columns `:price`
  and `:volume`. You may access these columns directly for numeric queries, but
  should generally prefer to work with `Refuel` structures for most rendering
  work.
  """
  @spec refuel(%__MODULE__{}) :: %Refuel{}
  def refuel(%__MODULE__{price: p, volume: v}) do
    changes = %Refuel{} |> Refuel.changeset(%{price: p, volume: v})

    if changes.valid? do
      changes |> apply_changes()
    else
      nil
    end
  end

  @doc """
  Renders the timestamp value in a relatively human-friendly manner.
  """
  def show_moment(%__MODULE__{moment: moment}),
    do: moment |> Timex.format!("{YYYY} {Mshort} {0D} at {h24}:{m}")

  @doc """
  Renders the odometer value with a delimiter every three digits
  """
  def show_odometer(%__MODULE__{odometer: odo}),
    do: odo |> Number.Delimit.number_to_delimited(precision: 1, delimiter: ",")

  @doc """
  Parses a row from a CSV batch-upload file.

  The CSV file **must** have the following columns:

  - `Date`: A datetime formatted as `YYYY-MM-DD hh:mm`. It is assumed to be UTC.
  - `Odometer`: An integer. Tenths are currently not supported.

  The CSV file *may* have the following columns:

  - `Price`: a decimal number. It may have a currency symbol; all non-number
    characters are removed before parsing.
  - `Volume`: a decimal number.
  """
  @spec parse_csv_row(%{String.t() => String.t()}) :: Ecto.Changeset.t() | nil
  def parse_csv_row(%{
        "Date" => date,
        "Odometer" => odometer,
        "Price" => price,
        "Volume" => volume
      }) do
    moment =
      case date |> Timex.parse("{YYYY}-{0M}-{0D} {h24}:{m}") do
        {:ok, moment} -> moment
        {:error, _} -> raise ArgumentError, "Failed to parse #{date}"
      end
      |> DateTime.from_naive!("Etc/UTC")

    price = Regex.replace(~r/[^0-9\.]*/, price, "")

    cs =
      %__MODULE__{}
      |> cast(%{odometer: odometer, moment: moment, price: price, volume: volume}, [
        :odometer,
        :moment,
        :price,
        :volume
      ])

    if cs.valid? do
      cs.changes
    else
      nil
    end
  end
end
