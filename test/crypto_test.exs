defmodule CryptoTest do
  use ExUnit.Case, async: true
  doctest Crypto

  test "Encode and decode with erasure coding returns original output" do
     input = DAG.Unit.new("creator_id", ["parent_1", "parent_2"], "test data")
     assert input |> Crypto.erasure_encode(2, 5) |> Crypto.erasure_decode() == input
  end
end
