defmodule Roadtrip.Garage.Refuel do
  @moduledoc """
  Describes a refueling event.

  This is an embedded schema whose columns are tracked in `Measurement`. It is
  broken out for application purposes, but is never persisted to the database.
  As such, its `.id` field will always be `nil` and meaningless.
  """

  use Roadtrip.Schema
  import Ecto.Changeset

  embedded_schema do
    field :price, :decimal
    field :volume, :decimal
  end

  @doc false
  def changeset(refuel, attrs) do
    refuel
    |> cast(attrs, [:price, :volume])
    |> validate_required([:price, :volume])
    |> change()
  end

  @doc """
  Computes the total cost (price times volume).
  """
  def total_cost(%__MODULE__{price: price, volume: volume}) do
    price |> Decimal.mult(volume)
  end

  @doc """
  Renders the refuel as "volume @ price (total)"
  """
  def show(%__MODULE__{price: price, volume: volume} = refuel, opts \\ []) do
    opts = [units: "gallons", unit: "$"] |> Keyword.merge(opts)
    total = refuel |> total_cost() |> Number.Currency.number_to_currency()
    price = price |> Number.Currency.number_to_currency(precision: 3)

    "#{volume |> Decimal.round(3)} #{opts[:units]} @ #{price} (#{total})"
  end
end
