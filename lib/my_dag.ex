defmodule MyDAG do
  @moduledoc """
  An Agent-based module to store a local copy of the DAG.
  """
  use Agent
  # alias MODULE__, as: M

  def start_link() do
    Driver.Node.debug("Starting a DAG on this process")
    Agent.start_link(fn -> DAG.new() end, name: name())
  end

  def max_round() do
    name() |> Agent.get(& &1 |> DAG.max_round())
  end

  def next_round() do
    name() |> Agent.get(& &1 |> DAG.next_round())
  end

  @spec add(non_neg_integer(), DAG.Unit.t) :: :ok
  def add(round, unit) do
    name() |> Agent.update(& &1 |> DAG.add(round, unit))
  end

  def local_add(round, unit) do
    name() |> Agent.update(& &1 |> DAG.local_add(round, unit))
  end

  def get_units_for_round(round) do
    name() |> Agent.get(& &1 |> DAG.get_units_for_round(round))
  end

  def get_my_parents(r) do
    name() |> Agent.get(& &1 |> DAG.get_latest_units(Driver.Node.peers, r))
  end

  def to_set() do
    name() |> Agent.get(& &1 |> DAG.to_set())
  end

  @doc """
  Returns the whole DAG as a DAG struct.
  """
  def dag() do
    name() |> Agent.get(& &1)
  end

  def name() do
    :"#{inspect(self())}-DAG"
  end
end
