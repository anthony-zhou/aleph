defmodule Driver.Node do
  use Agent

  def start(recv) do
    IO.puts("Started local node at #{self() |> inspect()}")
    receive do
      {:bind, _driver_pid, peers} ->
        state = %{
          n: length(peers),
          f: get_f_from_n(length(peers)),
          peers: peers
        }
        Agent.start_link(fn -> state end, name: __MODULE__)
        recv_loop(recv)
    end
  end

  defp recv_loop(recv) do
    receive do
      {:multicast, m} ->
        multicast(m)
      other ->
        recv.(other)
    end
    recv_loop(recv)
  end

  def multicast(m) do
    for p <- peers() do
      send(p, m)
    end
  end

  defp peers() do
    Agent.get(__MODULE__, fn state -> state.peers end)
  end

  @spec get_f_from_n(non_neg_integer()) :: non_neg_integer()
  defp get_f_from_n(n) do
    floor((n - 1) / 3)
  end
end
