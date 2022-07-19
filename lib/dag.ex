defmodule DAG do
  @moduledoc """
  A round-based Directed Acyclic Graph. Still a bit of a naive implementation.
  """
  alias __MODULE__, as: T

  defstruct graph: %{}, max_round: 0

  @typedoc """
  * `:graph`: A map that holds the DAG Units, indexed by DAG-round number.
  * `:max_round`: The largest DAG-round of a unit seen by this DAG instance.
  """
  @type t :: %T{
    graph: map(),
    max_round: non_neg_integer()
  }

  @doc """
  Creates an empty DAG.
  """
  def new do
    %T{}
  end

  @doc """
  Add a node to the DAG at the given round. It's assumed that the Unit and round are valid -- this function does no validation.
  """
  @spec add(t, non_neg_integer(), T.Unit.t()) :: t
  def add(%T{} = t, round, unit) do
    if round > t.max_round do
      %T{t |
        graph: Map.update(t.graph, round, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),
        max_round: round }
    else
      %T{t | graph: Map.update(t.graph, round, MapSet.new([unit]), &(&1 |> MapSet.put(unit))) }
    end
  end

  @spec max_round(t) :: non_neg_integer()
  def max_round(%T{} = t), do: t.max_round

  @doc """
  Returns a flattened set of all the Units in the DAG.
  """
  @spec to_set(t) :: MapSet.t(T.Unit.t)
  def to_set(%T{} = t) do
    t.graph |> Enum.reduce(MapSet.new(), fn ({_round, vertex_set}, acc) -> MapSet.union(acc, vertex_set) end)
  end



end
