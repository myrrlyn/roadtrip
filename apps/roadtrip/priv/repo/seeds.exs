# Script for populating the database. You can run it as:
#
#     mix ecto.seed
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Roadtrip.Repo.insert!(%Roadtrip.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Roadtrip.{Garage, Repo}

"assets/garage.csv"
|> File.stream!()
|> CSV.decode(headers: true)
|> Stream.map(fn {:ok, map} -> map end)
|> Stream.map(fn %{"Name" => name, "Make" => make, "Model" => model, "Year" => year, "VIN" => vin} ->
  %{name: name, make: make, model: model, year: year, vin: vin}
end)
|> Stream.map(&Garage.create_vehicle/1)
|> Stream.run()

savah = Repo.get_by!(Garage.Vehicle, name: "Savah")

"assets/savah.csv"
|> File.stream!()
|> CSV.decode(headers: true)
|> Stream.map(fn {:ok, map} -> map end)
|> Stream.map(&Garage.Measurement.parse_csv_row/1)
|> Stream.map(&(&1 |> Map.put(:vehicle_id, savah.id)))
|> Stream.map(&Garage.create_measurement/1)
|> Stream.run()
