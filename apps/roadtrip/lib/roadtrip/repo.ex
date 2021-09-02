defmodule Roadtrip.Repo do
  use Ecto.Repo,
    otp_app: :roadtrip,
    adapter: Ecto.Adapters.Postgres
end
