defmodule Driver.Node do
  use Agent
  defstruct n: 0, f: 0, peers: []

  alias __MODULE__, as: T

  def start(recv, output) do
    IO.puts("Started local node at #{self() |> inspect()}")
    receive do
      {:bind, _driver_pid, peers} ->
        state = %T{
          n: length(peers),
          f: get_f_from_n(length(peers)),
          peers: peers
        }
        Agent.start_link(fn -> state end, name: T)
        Aleph.start(output)
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

  def n, do: Agent.get(T, & &1.n)
  def f, do: Agent.get(T, & &1.f)

  def peers() do
    Agent.get(T, fn state -> state.peers end)
  end

  @spec get_f_from_n(non_neg_integer()) :: non_neg_integer()
  defp get_f_from_n(n) do
    floor(n / 3)
  end

  def debug(msg) do
    IO.puts("[#{inspect(self())}]: #{inspect(msg)}")
  end
end
