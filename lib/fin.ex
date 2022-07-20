# Desired API:
# record_transaction(from: alice, to: bob, amount: 100)

defmodule Fin do
  @moduledoc false

  def start(output) do
    RBC.start(output)
    MyDAG.start_link()
  end


  # def record_transaction(from, to, amount) do

  # end

  # def broadcast(message) do
  #   Fin.RBC.broadcast(message)
  # end

  # def deliver(message) do

  # end





end
