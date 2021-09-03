defmodule Roadtrip.Garage.Vin do
  @moduledoc """
  Provides utilities for working with (North American) VIN sequences.
  """

  def length(), do: 17

  def na_weights(), do: [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]

  @doc """
  Provides a value that can be used in `<input pattern=… />` HTML tags.
  """
  @spec html_input_pattern() :: String.t()
  def html_input_pattern(), do: "[0-9A-HJ-NPR-Za-hj-npr-z]{#{length()}}"

  @doc """
  Computes the North-American checksum for a VIN.

  This uses the standard North American checksum algorithm, which is explained
  in detail on [Wikipedia][0].

  ## Examples

  ```elixir
  iex> Roadtrip.Garage.Vin.na_checksum("4S4BSANC6K3352864")
  {:ok, "4S4BSANC6K3352864"}

  iex> Roadtrip.Garage.Vin.na_checksum("4S4BSANC6K335286") # digit deleted
  {:error, "VINs must be 17 ASCII alphanumeric digits (excepting I, O, and Q)"}

  iex> Roadtrip.Garage.Vin.na_checksum("4S4BSANC7K3352864") # checksum changed
  {:warn, "VIN checksum does not match"}

  iex> Roadtrip.Garage.Vin.na_checksum("abcdefghijklmnopq")
  {:error, "Letter `i` is outside the valid VIN character set"}
  ```

  [0]: https://en.wikipedia.org/wiki/Vehicle_identification_number#Check-digit_calculation
  """
  @spec na_checksum(String.t()) :: {:ok | :warn | :error, String.t()}
  def na_checksum(vin) when is_binary(vin) do
    cond do
      vin |> String.length() != length() ->
        {:error, "VINs must be #{length()} ASCII alphanumeric digits (excepting I, O, and Q)"}

      vin |> weigh() |> Integer.mod(11) |> check_digit() != vin |> String.at(8) ->
        {:warn, "VIN checksum does not match"}

      true ->
        {:ok, vin}
    end
  rescue
    err in ArgumentError -> {:error, err.message}
  end

  @doc """
  Modifies a VIN so that it passes the North American checksum computation.
  """
  @spec write_na_checksum(String.t()) :: String.t()
  def write_na_checksum(vin) when is_binary(vin) do
    case vin |> na_checksum() do
      {:ok, vin} ->
        vin

      {:warn, "VIN checksum does not match"} ->
        digit = vin |> weigh() |> Integer.mod(11) |> check_digit()
        front = vin |> String.slice(0..7)
        back = vin |> String.slice(9..16)
        front <> digit <> back

      {:error, msg} ->
        raise ArgumentError, msg
    end
  end

  @doc """
  Computes the total “weight” for a VIN sequence. The algorithm maps each digit
  in the VIN down to a number in 1-9, multiplies it by a weighting factor
  corresponding to its position in the VIN, then sums them all together.

  The total weight is reduced by modulus-11 and translated back into a VIN digit
  for checksumming.
  """
  @spec weigh(String.t()) :: integer()
  def weigh(vin) when is_binary(vin), do: weigh(vin, na_weights())

  @spec weigh(String.t(), [integer()]) :: integer()
  def weigh(vin_fragment, weights_fragment)
      when is_binary(vin_fragment) and is_list(weights_fragment) do
    case {vin_fragment |> String.next_codepoint(), weights_fragment} do
      {nil, _} ->
        0

      {_, []} ->
        0

      {{letter, vin_rest}, [weight | weights_rest]} ->
        transliterate(letter) * weight + weigh(vin_rest, weights_rest)
    end
  end

  @doc """
  Transliterates VIN digits (ASCII alphanumeric except I/O/Q) into their
  corresponding numeric value.
  """
  @spec transliterate(binary) :: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
  def transliterate("0"), do: 0

  def transliterate(letter) when is_binary(letter) do
    cond do
      "1AaJj" |> String.contains?(letter) -> 1
      "2BbKkSs" |> String.contains?(letter) -> 2
      "3CcLlTt" |> String.contains?(letter) -> 3
      "4DdMmUu" |> String.contains?(letter) -> 4
      "5EeNnVv" |> String.contains?(letter) -> 5
      "6FfWw" |> String.contains?(letter) -> 6
      "7GgPpXx" |> String.contains?(letter) -> 7
      "8HhYy" |> String.contains?(letter) -> 8
      "9RrZz" |> String.contains?(letter) -> 9
      true -> raise ArgumentError, "Letter `#{letter}` is outside the valid VIN character set"
    end
  end

  @spec check_digit(integer()) :: String.t()
  defp check_digit(10), do: "X"
  defp check_digit(n) when n >= 0 and n < 10, do: to_string(n)
end
