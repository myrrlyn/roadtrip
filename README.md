# Roadtrip

This application tracks vehicle usage over time. It allows users to upload
snapshots of their car’s odometer and any associated data, such as location,
refuel, or maintenance, and see this data over time for analysis.

## Usage

I am building Roadtrip as a replacement for the spreadsheet I currently use to
track my vehicle use. My goals are to completely replace the functionality I
built in the spreadsheet; once I am there, I’ll hopefully know more about the
problem domain to decide what to do next.

This is an Elixir application. You’ll need to install Erlang/OTP and Elixir;
then you can `mix phx.server` in the project root to start a local web server.

It currently expects a PostgreSQL database. The default `:dev` environment is
configured to connect to a Postgres daemon at `localhost:5432` with credentials
`postgres:postgres`. Change `config/dev.exs` to correctly select a Postgres
instance as appropriate.

## Features

- The system can describe vehicles
- The system can describe measurements for vehicles
- The system can accept a CSV file of vehicle history for batch upload

## Roadmap

1. Extend `Measurement` with `Refuel` and `Maintenance` attachments
1. Extend `Measurement` with location attachments
1. Create query systems for `Measurements`, like fuel or maintenance forecast
1. Create CSV import/export behavior.
1. Add `Driver`s who can take ownership of `Vehicle`s
1. Implement permissions so that only owning `Driver`s can write to a `Vehicle`,
   and each `Vehicle` can be made publicly readable or opaque.

## Contributing

Contributions are welcome, but this is a purely personal project. I make no
promises to consideration or implementation.
