defmodule RoadtripWeb.MeasurementController do
  use RoadtripWeb, :controller

  alias Roadtrip.{Garage, Garage.Measurement, Repo}

  def index(conn, %{"vehicle_vin" => vin}) do
    vehicle = vin |> Garage.get_vehicle_by_vin!()
    measurements = vehicle |> Garage.list_measurements()
    conn |> render("index.html", measurements: measurements, vehicle: vehicle)
  end

  def new(conn, %{"vehicle_vin" => vin}) do
    vehicle = vin |> Garage.get_vehicle_by_vin!()
    changeset = Garage.change_measurement(%Measurement{})
    conn |> render("new.html", changeset: changeset, vehicle: vehicle)
  end

  def create(conn, %{"vehicle_vin" => vin, "measurement" => measurement_params}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)

    case Garage.create_measurement(measurement_params) do
      {:ok, measurement} ->
        conn
        |> put_flash(:info, "Measurement created successfully.")
        |> redirect(to: Routes.vehicle_measurement_path(conn, :show, vehicle, measurement))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn |> render("new.html", changeset: changeset, vehicle: vehicle)
    end
  end

  def show(conn, %{"vehicle_vin" => vin, "moment" => moment}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)

    measurement =
      Garage.get_measurement!(vehicle, moment |> from_param()) |> Repo.preload(:vehicle)

    conn |> render("show.html", measurement: measurement, vehicle: measurement.vehicle)
  end

  def edit(conn, %{"vehicle_vin" => vin, "moment" => moment}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)

    measurement =
      Garage.get_measurement!(vehicle, moment |> from_param()) |> Repo.preload(:vehicle)

    changeset = Garage.change_measurement(measurement)

    conn
    |> render("edit.html",
      measurement: measurement,
      changeset: changeset,
      vehicle: measurement.vehicle
    )
  end

  def update(conn, %{
        "vehicle_vin" => vin,
        "moment" => moment,
        "measurement" => measurement_params
      }) do
    vehicle = Garage.get_vehicle_by_vin!(vin)
    measurement = Garage.get_measurement!(vehicle, moment |> from_param())

    case Garage.update_measurement(measurement, measurement_params) do
      {:ok, measurement} ->
        conn
        |> put_flash(:info, "Measurement updated successfully.")
        |> redirect(to: Routes.vehicle_measurement_path(conn, :show, vehicle, measurement))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("edit.html", measurement: measurement, changeset: changeset, vehicle: vehicle)
    end
  end

  def delete(conn, %{"vehicle_vin" => vin, "moment" => moment}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)
    measurement = Garage.get_measurement!(vehicle, moment |> from_param())
    {:ok, _measurement} = Garage.delete_measurement(measurement)

    conn
    |> put_flash(:info, "Measurement deleted successfully.")
    |> redirect(to: Routes.vehicle_measurement_path(conn, :index, vehicle))
  end

  @doc """
  Renders the page to upload a batch collection of odometer measurements.
  """
  def batch_upload_form(conn, %{"vehicle_vin" => vin}) do
    vehicle = Garage.get_vehicle_by_vin!(vin)
    conn |> render("batch.html", vehicle: vehicle)
  end

  @doc """
  Processes a CSV batch of `Measurement` records.

  Duplicate this function with other `content_type:` values for other filetypes.

  ## CSV Format

  See `Measurement.parse_csv_row/1`.
  """
  def batch_upload(
        conn,
        %{
          "vehicle_vin" => vin,
          "upload" => %{
            "file" => %Plug.Upload{path: path, content_type: "text/csv"}
          }
        }
      ) do
    vehicle = Garage.get_vehicle_by_vin!(vin)

    path
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Stream.map(fn {:ok, row} -> row end)
    |> Stream.map(&Measurement.parse_csv_row/1)
    |> Garage.batch_create_measurements(vehicle)

    conn |> redirect(to: Routes.vehicle_measurement_path(conn, :index, vehicle))
  end

  # Since `Phoenix.Param.to_param` replaces `:` with `-`, this turns the param
  # back into a usable `DateTime`.
  @spec from_param(String.t()) :: DateTime.t()
  defp from_param(moment_str) when is_binary(moment_str) do
    re = ~r/^(?<Y>\d{4})-(?<M>\d{2})-(?<D>\d{2})T(?<h>\d{2})-(?<m>\d{2})-(?<s>\d{2})Z$/

    %{"Y" => yr, "M" => mo, "D" => dy, "h" => hr, "m" => mn, "s" => sc} =
      Regex.named_captures(re, moment_str)

    {year, ""} = yr |> Integer.parse()
    {month, ""} = mo |> Integer.parse()
    {day, ""} = dy |> Integer.parse()
    {hour, ""} = hr |> Integer.parse()
    {minute, ""} = mn |> Integer.parse()
    {second, ""} = sc |> Integer.parse()
    date = Date.new!(year, month, day)
    time = Time.new!(hour, minute, second)
    DateTime.new!(date, time)
  end
end

defimpl Phoenix.Param, for: Roadtrip.Garage.Measurement do
  def to_param(%Roadtrip.Garage.Measurement{moment: moment}) do
    moment
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601(:extended)
    |> String.replace(":", "-")
  end
end
