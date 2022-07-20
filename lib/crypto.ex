defmodule Crypto do
  @moduledoc """
  A module of cryptography utility functions.
  """

  @doc """
  Split a piece of data into n pieces using erasure encoding, given at most m failures.
  For now, we'll just chunk the data evenly.
  TODO: update this and the decode function to use actual erasure.
  """
  @spec erasure_encode(DAG.Unit.t, non_neg_integer(), non_neg_integer()) :: list(String.t)
  def erasure_encode(unit, _m, n) do
    # Ignore m for now -- we will use this in actual erasure encoding.
    json = unit |> Map.from_struct() |> Jason.encode!() |> String.to_charlist()
    chunk_size = ceil(length(json) / n)

    json
      |> Enum.chunk_every(chunk_size)
  end

  @spec erasure_decode(list(list(char))) :: Unit.t
  def erasure_decode(s) do
    m = s
      |> Enum.reduce(fn (chunk, acc) -> acc ++ chunk end)
      |> to_string()
      |> Jason.decode!()
      |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)

    struct(DAG.Unit, m)
  end
end
