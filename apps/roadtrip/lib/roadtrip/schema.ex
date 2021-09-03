defmodule Roadtrip.Schema do
  @moduledoc """
  Common settings for all database schemas used in the application.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      # Force UTC timestamps
      @timestamp_opts type: :utc_datetime
    end
  end
end
