defmodule RBC.State do
  @moduledoc """
  An Agent module to store state for the RBC protocol.
  """
  use Agent

  # alias __MODULE__, as: T

  # Underlying data structure:
  # { <prevote, val>: count, <commit, val>: count, prevote: bool, vote: bool}

  def start_link() do
    Agent.start_link(fn -> %{} end, name: name())
  end

  @doc """
  Clear the state so that we can begin a new round of RBC.
  """
  def reset() do
    Agent.update(name(), fn _ -> %{} end)
  end

  @doc """
  Check if this node already received a proposal from the sender for this round.
  """
  @spec received_propose(pid, non_neg_integer) :: boolean
  def received_propose(sender, round) when is_pid(sender) do
    name() |> Agent.get(& !!&1["#{inspect(sender)}-#{round}"])
  end

  @doc """
  Mark that this node has received a proposal from the sender for this round.
  """
  @spec received_propose(pid, non_neg_integer) :: boolean
  def mark_received_propose(sender, round) when is_pid(sender) do
    name() |> Agent.update(& (&1 |> Map.put("#{inspect(sender)}-#{round}", true)))
  end

  def get_and_increment(key) do
    Agent.get_and_update(name(), fn state -> {Map.get(state, key), Map.update(state, key, 0, &(&1 + 1))} end)
  end
  @doc """
  Given the merkle tree root, fetch the associated erasure codes and merkle leaves.
  """
  def get(:prevote, h) do
    Agent.get(name(), & Map.get(&1, "<prevote, #{h}>", []))
  end
  def get(:commit, r, h) do
    Agent.get(name(), & Map.get(&1, "<commit, #{r}, #{h}>", 0))
  end
  def has_committed?(), do: Agent.get(name(), & Map.get(&1, :commit, false))

  @doc """
  Mark down the prevote received, with the Merkle root h, erasure code s, and Merkle leaf b.
  """
  def prevote(h, b, s) do
    Agent.update(name(), & Map.update(&1, "<prevote, #{h}>", MapSet.new([%{b: b, s: s}]),  fn l ->  MapSet.put(l, %{b: b, s: s}) end))
  end
  def increment(:commit, r, h) do
    Agent.update(name(), & Map.update(&1, "<commit, #{r}, #{h}>", 1, fn count -> count + 1 end))
  end
  def set(:commit, has_committed?), do: Agent.update(name(), & Map.put(&1, :commit, has_committed?))

  def name() do
    :"#{inspect(self())}-rbc"
  end
end
