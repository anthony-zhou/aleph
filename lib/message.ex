defmodule Message do
  defstruct sender: nil, index: nil, payload: nil, predecessors: nil, info: nil

  @type t :: %Message{sender: String.t(), index: integer, payload: String.t(), predecessors: list(String.t()), info: String.t()}
end
