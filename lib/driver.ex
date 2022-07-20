defmodule Driver do
  @moduledoc """
  A module that starts distributed nodes to test them.
  """

  def recv(msg) do
    case msg do
      {:create_unit, data} ->
        {unit, r} = DAG.Grow.create_unit(data)
        Driver.Node.multicast(RBC.init_msg(self(), unit, r))
      {:inspect_dag} ->
        IO.puts("Here's the DAG")
        IO.inspect(MyDAG.to_set())
      m -> RBC.recv(m)
    end
  end

  def output({r, unit}) do
    RBC.debug("Output is {#{r}, #{inspect(unit)}}")
    DAG.Grow.receive_unit(r, unit)
  end

  def start() do
    peers = Enum.map(0..4, fn _ -> spawn(Driver.Node, :start, [&recv/1, &output/1]) end)

    for p <- peers, do: send(p, {:bind, self(), peers})

    # Go round robin and broadcast data to each node
    for _r <- 0..5 do
      for p <- peers do
        Process.sleep(200)
        # Deliver a message
        send(p, {:create_unit, "Hey this is a transaction"})
      end
    end

    send(List.first(peers), {:inspect_dag})
  end
end
