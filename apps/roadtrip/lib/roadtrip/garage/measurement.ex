defmodule Roadtrip.Garage.Measurement do
  @moduledoc """
  Describes an odometer measurement for a vehicle.

  Measurements are always odometer/timestamp pairs. They may be extended with
  additional information in the future.
  """

  use Roadtrip.Schema
  import Ecto.Changeset
  alias Roadtrip.Garage.Vehicle

  schema "measurements" do
    field :odometer, :integer
    field :moment, :utc_datetime

    belongs_to :vehicle, Vehicle

    timestamps()
  end

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, [:odometer, :moment, :vehicle_id])
    |> validate_required([:odometer, :moment, :vehicle_id])
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
    do: odo |> Number.Delimit.number_to_delimited(precision: 0, delimiter: ",")

  @doc """
  Parses a row from a CSV batch-upload file.

  The CSV file **must** have the following columns:

  - `Date`: A datetime formatted as `YYYY-MM-DD hh:mm`. It is assumed to be UTC.
  - `Odometer`: An integer. Tenths are currently not supported.

  The CSV file *may* have the following columns:

  > No optional columns are currently supported.
  """
  @spec parse_csv_row(%{String.t() => String.t()}) :: %{atom() => any()}
  def parse_csv_row(%{"Date" => date, "Odometer" => odo}) do
    moment =
      case date |> Timex.parse("{YYYY}-{0M}-{0D} {h24}:{m}") do
        {:ok, moment} -> moment
        {:error, _} -> raise ArgumentError, "Failed to parse #{date}"
      end
      |> DateTime.from_naive!("Etc/UTC")

    {odometer, ""} = odo |> Integer.parse()

    %{
      moment: moment,
      odometer: odometer
    }
  end
end
