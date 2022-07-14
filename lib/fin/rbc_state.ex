defmodule Fin.RBCState do
  use Agent

  # Underlying data structure:
  # { <echo, val>: count, <vote, val>: count, echo: bool, vote: bool}

  def start_link(initial_value) do
    IO.puts("start link called")
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
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

  # def get_key(:echo, val) do
  #   "<echo, #{val}>"
  # end

  # def get_key(:vote, val) do
  #   "<vote, #{val}>"
  # end

  # def increment(pid, key) do
  #   GenServer.call(pid, {:increment, key})
  # end

  # def get_state(pid) do
  #   GenServer.call(pid, {:get_state})
  # end

  # def get(pid, key) do
  #   GenServer.call(pid, {:get, key})
  # end

  # def mark_echoed(pid) do
  #   GenServer.call(pid, {:set, :echo})
  # end

  # def mark_voted(pid) do
  #   GenServer.call(pid, {:set, :vote})
  # end

  # @impl true
  # def handle_call({:increment, key}, _from, state) do
  #   {:reply, "Incrementing #{key}", Map.update(state, key, 1, &(&1 + 1))}
  # end

  # @impl true
  # def handle_call({:get_state}, _from, state) do
  #   IO.inspect(state)
  #   {:reply, "Here's the state", state}
  # end

  # @impl true
  # def handle_call({:set, key}, _from, state) do
  #   {:reply, "Here's the state", Map.put(state, key, false)}
  # end

  # @impl true
  # def handle_call({:get, key}, _from, state) do
  #   {:reply, Map.get(state, key, 0), state}
  # end
end
