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
  def add(%T{} = t, r, unit) do
    if r > t.max_round do
        %T{t |
          graph: Map.update(t.graph, r, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),
          creator_indexed_graph: Map.update(t.creator_indexed_graph, unit.creator, [%{round: r, unit: unit}], fn l -> [%{round: r, unit: unit} | l] end),
          max_round: r }
    else
        %T{t | graph: Map.update(t.graph, r, MapSet.new([unit]), &(&1 |> MapSet.put(unit))),
        creator_indexed_graph: Map.update(t.creator_indexed_graph, unit.creator, [%{round: r, unit: unit}], fn l -> [%{round: r, unit: unit} | l] end)}
    end
  end

  @doc """
  Add a node to the DAG at the given round for the local unit. This is similar to add() but it also increments current_round.
  """
  @spec add(t, non_neg_integer(), T.Unit.t()) :: t
  def local_add(%T{} = t, r, unit) do
    new_graph = t |> add(r, unit)
    %T{new_graph | next_round: t.next_round + 1}
  end

  @doc """
  Returns the units in the given round of the graph.
  """
  @spec get_units_for_round(t, non_neg_integer()) :: MapSet.t(DAG.Unit.t())
  def get_units_for_round(%T{} = t, round) do
    t.graph[round] || MapSet.new()
  end

  @doc """
  Gets the latest unit sent by each node in `nodes`
  TODO: make sure the round of these units is less than the round `r` of the unit being added.
  """
  def get_latest_units(%T{} = t, nodes, r) do
    nodes
    |> Enum.map(fn node -> DAG.Creator.get_id(node) end)
    |> Enum.map(fn id -> get_latest_unit_earlier_than(r, id, t) end)
    |> Enum.filter(&(&1 != nil))
  end

  # Get the latest unit earlier than round `r` for node `id` in `t`.
  defp get_latest_unit_earlier_than(r, id, %T{} = t) do
    latest = (t.creator_indexed_graph[id] || [])
      |> Enum.find(fn item -> item.round < r end)
    case latest do
      nil -> nil
      _ -> latest.unit
    end
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
