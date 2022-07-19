defmodule DagTest do
  use ExUnit.Case, async: true
  doctest DAG
  alias DAG.Unit

  test :add do
     assert DAG.new() |> DAG.add(0, Unit.new()) |> DAG.to_set() == MapSet.new([Unit.new()])
     assert DAG.new() |> DAG.add(0, Unit.new()) |> DAG.add(1, Unit.new()) |> DAG.to_set() == MapSet.new([Unit.new(), Unit.new()])
  end

  test :max_round do
    assert DAG.new() |> DAG.max_round() == 0
    assert DAG.new() |> DAG.add(0, Unit.new()) |> DAG.add(1, Unit.new()) |> DAG.max_round() == 1
  end
end
