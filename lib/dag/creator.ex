defmodule DAG.Creator do
  @type t :: String.t()

  @doc """
  Create a new creator ID.
  TODO: Eventually sub this out with a stateful keypair.
  """
  def new do
    "#{inspect(self())}-pk"
  end

  @doc """
  Get this node's creator ID.
  """
  def myself do
    "#{inspect(self())}-pk"
  end

  @doc """
  Get the ID for a given node. Later on this will use the stateful keypairs available on-chain.
  """
  def get_id(pid) do
    "#{inspect(pid)}-pk"
  end
end
