defmodule Fin.RBC do
  @n 4
  @f 1

  @spec receive_multicast({Node.t(), Message.t()}) :: any()
  def receive_multicast({node, message}) do
    case message.payload do
      {:echo, v} ->
        IO.puts("Echo received from #{node}")
        Fin.RBCState.increment(:echo, v)
        if Fin.RBCState.get(:echo, v) == @n - @f and Fin.RBCState.vote? do
          multicast(%Message{sender: self(), payload: {:vote, v}})
          Fin.RBCState.set_vote(false)
        end
      {:vote, v} ->
        IO.puts("Vote received from #{node}")
        Fin.RBCState.increment(:vote, v)
        if Fin.RBCState.get(:vote, v) == @f + 1 and Fin.RBCState.vote? do
          multicast(%Message{sender: self(), payload: {:vote, v}})
          Fin.RBCState.set_vote(false)
        end
        if Fin.RBCState.get(:vote, v) == @n - @f do
          IO.puts("CONSENSUS REACHED. TIME TO DELIVER #{v}")
          # Todo: integrate this with round numbers from DAG
          # Otherwise RBCState just gets set and never reset.
        end
      {:initial, v} ->
        IO.puts("Received #{v} from #{node}")
        if Fin.RBCState.echo? do
          multicast(%Message{sender: self(), payload: {:echo, v}})
          Fin.RBCState.set_echo(false)
        end
    end
  end

  @spec multicast(Message.t()) :: any()
  def multicast(message) do
    multicast_msg = {node(), message}
    nodes()
    |> Enum.map(fn node -> spawn_task(__MODULE__, :receive_multicast, node, [multicast_msg]) end)
  end

  @spec broadcast(Message.t()) :: any()
  def broadcast(message) do
    multicast(message)
  end

  defp spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, fun, args)
    |> Task.await()
  end

  defp remote_supervisor(recipient) do
    Application.get_env(:fin, :remote_supervisor).(recipient)
  end

  # Return a list of the nodes in the cluster.
  def nodes do
    # [:bob@localhost, :charlie@localhost]
    [:alice@localhost, :bob@localhost, :charlie@localhost, :david@localhost]
  end

end
