defmodule Driver do
  @moduledoc """
  A module that starts distributed nodes to test them.
  """

  def recv(msg) do
    case msg do
      m -> IO.puts("Received: #{m}")
    end
  end

  def start() do
    peers = Enum.map(0..4, fn _ -> spawn(Driver.Node, :start, [&recv/1]) end)

    for p <- peers, do: send(p, {:bind, self(), peers})

    # Tell Alice to multicast a message.
    alice = peers |> List.first()
    send(alice, {:multicast, "Hey"})
  end
end
