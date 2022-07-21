defmodule DriverTest do
  use ExUnit.Case, async: true
  doctest Driver

  test "Test node network with 3 nodes, 3 rounds" do
    assert Driver.start(3, 3) |> DAG.max_round() == 2
  end
end
