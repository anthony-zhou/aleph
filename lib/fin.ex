defmodule Fin do
  @moduledoc false

  def start(output) do
    RBC.start(output)
    MyDAG.start_link()
  end
end
