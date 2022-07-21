defmodule Driver do
  @moduledoc """
  A module that starts distributed nodes to test them.
  """

  def recv(msg) do
    case msg do
      {:create_unit, data} ->
        {unit, r} = DAG.Grow.create_unit(data)
        Driver.Node.multicast(RBC.init_msg(self(), unit, r))
      {:inspect_dag, request_pid} ->
        send(request_pid, {:DAG, MyDAG.dag()})
      m -> RBC.recv(m)
    end
  end

  def output({r, unit}) do
    Driver.Node.debug("Output is {#{r}, #{inspect(unit)}}")
    DAG.Grow.receive_unit(r, unit)
  end

  def start(node_count, rounds) do
    peers = Enum.map(0..(node_count-1), fn _ -> spawn(Driver.Node, :start, [&recv/1, &output/1]) end)

    for p <- peers, do: send(p, {:bind, self(), peers})

    # Go round robin and broadcast data to each node
    for i <- 0..(rounds-1) do
      for p <- peers do
        Process.sleep(100)
        # Deliver a message
        send(p, {:create_unit, "Hey this is a transaction in round #{i}"})
      end
    end

    # Fetch the DAG.
    send(List.first(peers), {:inspect_dag, self()})
    receive do
      {:DAG, dag} ->
        IO.inspect(dag.graph)
        dag
    end
  end
end
