defmodule DAG do
  @moduledoc """
  A round-based Directed Acyclic Graph. Still a bit of a naive implementation.
  """
  alias __MODULE__, as: T

  defstruct graph: %{}, max_round: 0, next_round: 0, creator_indexed_graph: %{}

  @typedoc """
  * `:graph`: A map that holds the DAG Units, indexed by DAG-round number.
  * `:max_round`: The largest DAG-round of a unit seen by this DAG instance.
  """
  @type t :: %T{
    graph: map,
    creator_indexed_graph: map,
    max_round: non_neg_integer,
    next_round: non_neg_integer
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
      if unit.creator == DAG.Creator.myself() do
        %T{t |
        graph: Map.update(t.graph, round, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),
        creator_indexed_graph: Map.update(t.creator_indexed_graph, unit.creator, [unit], fn l -> [unit | l] end),
        max_round: round,
        next_round: t.next_round + 1 }
      else
        %T{t |
          graph: Map.update(t.graph, round, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),
          creator_indexed_graph: Map.update(t.creator_indexed_graph, unit.creator, [unit], fn l -> [unit | l] end),
          max_round: round }
      end
    else
      if unit.creator == DAG.Creator.myself() do
        %T{t |
          graph: Map.update(t.graph, round, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),
          creator_indexed_graph: Map.update(t.creator_indexed_graph, unit.creator, [unit], fn l -> [unit | l] end),
          next_round: t.next_round + 1
        }
      else
        %T{t | graph: Map.update(t.graph, round, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),        creator_indexed_graph: Map.update(t.creator_indexed_graph, unit.creator, [unit], fn l -> [unit | l] end)
      }
      end
    end
  end

  @doc """
  Returns the units in the given round of the graph.
  """
  @spec get_units_for_round(t, non_neg_integer()) :: MapSet.t(DAG.Unit.t())
  def get_units_for_round(%T{} = t, round) do
    t.graph[round]
  end

  @doc """
  Gets the latest unit sent by each node in `nodes`
  TODO: make sure the round of these units is less than the round `r` of the unit being added.
  """
  def get_latest_units(%T{} = t, nodes) do
    nodes
    |> Enum.map(fn node -> DAG.Creator.get_id(node) end)
    |> Enum.map(fn id -> (t.creator_indexed_graph[id] || []) |> List.first() end)
    |> Enum.filter(&(&1 != nil))
  end

  @doc """
  Returns the maximum round seen by this DAG copy.
  """
  @spec max_round(t) :: non_neg_integer()
  def max_round(%T{} = t), do: t.max_round

  @doc """
  Returns a flattened set of all the Units in the DAG.
  """
  @spec to_set(t) :: MapSet.t(T.Unit.t)
  def to_set(%T{} = t) do
    t.graph |> Enum.reduce(MapSet.new(), fn ({_round, vertex_set}, acc) -> MapSet.union(acc, vertex_set) end)
  end

  @doc """
  Returns the next round number that this DAG is able to add.
  """
  @spec next_round(t) :: non_neg_integer
  def next_round(%T{} = t), do: t.next_round

end
