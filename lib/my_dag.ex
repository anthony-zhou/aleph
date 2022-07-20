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


end
