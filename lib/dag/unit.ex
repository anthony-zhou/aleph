defmodule DAG.Unit do
  @moduledoc """
  A unit within the DAG, which contains a creator,
  a list of predecessors, and an optional data payload.
  """
  @derive Jason.Encoder

  alias __MODULE__, as: T

  defstruct creator: nil, parents: [], data: nil
  @type t :: %__MODULE__{
    creator: String.t(),
    parents: list(String.t()),
    data: String.t()
  }

  def new(creator, parents, data) do
    %T{creator: creator, parents: parents, data: data}
  end

  def new do
    %T{}
  end
end
