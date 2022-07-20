defmodule MyDAG do
  @moduledoc """
  An Agent-based module to store a local copy of the DAG.
  """
  use Agent
  alias __MODULE__, as: M

  def start_link() do
    Agent.start_link(fn -> DAG.new() end, name: M)
  end

  def max_round() do
    M |> Agent.get(& &1 |> DAG.max_round())
  end

  def next_round() do
    M |> Agent.get(& &1 |> DAG.next_round())
  end

  @spec add(non_neg_integer(), DAG.Unit.t) :: :ok
  def add(round, unit) do
    M |> Agent.update(& &1 |> DAG.add(round, unit))
  end

  def get_units_for_round(round) do
    M |> Agent.get(& &1 |> DAG.get_units_for_round(round))
  end

  # TODO: use the round number `r` to perform a filter by rounds < r.
  def get_my_parents(_r) do
    M |> Agent.get(& &1 |> DAG.get_latest_units(Driver.Node.peers))
  end

  def to_set() do
    M |> Agent.get(& &1 |> DAG.to_set())
  end
end
