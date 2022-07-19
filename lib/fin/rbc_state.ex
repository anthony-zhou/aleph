defmodule Fin.RBCState do
  use Agent

  # Underlying data structure:
  # { <echo, val>: count, <vote, val>: count, echo: bool, vote: bool}

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end
  def get_and_increment(key) do
    Agent.get_and_update(__MODULE__, fn state -> {Map.get(state, key), Map.update(state, key, 0, &(&1 + 1))} end)
  end
  def get(:echo, val) do
    Agent.get(__MODULE__, & Map.get(&1, "<echo, #{val}>", 0))
  end
  def get(:vote, val) do
    Agent.get(__MODULE__, & Map.get(&1, "<vote, #{val}>", 0))
  end
  def echo?(), do: Agent.get(__MODULE__, & Map.get(&1, :echo, false))
  def vote?(), do: Agent.get(__MODULE__, & Map.get(&1, :vote, false))

  def increment(:echo, val) do
    Agent.update(__MODULE__, & Map.update(&1, "<echo, #{val}>", 1, fn count -> count + 1 end))
  end
  def increment(:vote, val) do
    Agent.update(__MODULE__, & Map.update(&1, "<vote, #{val}>", 1, fn count -> count + 1 end))
  end
  def set_echo(echo?), do: Agent.update(__MODULE__, & Map.put(&1, :echo, echo?))
  def set_vote(vote?), do: Agent.update(__MODULE__, & Map.put(&1, :vote, vote?))
end
