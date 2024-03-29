defmodule RBC do
  @moduledoc """
  Validated reliable broadcast for the DAG consensus protocol.
  """
  alias Driver.Node, as: N
  use Agent


  def start(output_fn) do
    RBC.State.start_link()
    Agent.start_link(fn -> %{output: output_fn} end, name: __MODULE__)
  end

  def output(value) do
    Agent.get(__MODULE__, fn state -> state[:output] end).(value)
  end

  def init_msg(sender, m, r) do
    wrap_msg(sender, {:init, m}, r)
  end

  def wrap_msg(sender, m, r) do
    {:rbc, sender, m, r}
  end

  def rbc_send(peer, m, r) do
    send(peer, wrap_msg(self(), m, r))
  end

  def recv({:rbc, sender, {:init, m}, r}) do
    recipient = self() # The current node's id
    if sender == recipient do
      # Generate an erasure coding for U
      s = Crypto.erasure_encode(m, N.f + 1, N.n)
      # Generate merkle tree root for {s_j}
      mt = s |> MerkleTree.new(default_data_block: "")
      h = mt.root.value

      s = s |> List.to_tuple() # Convert to tuple for easy indexing
      N.peers
      |> Enum.with_index()
      |> Enum.each(fn {peer, i} ->
        b_i = mt |> MerkleTree.Proof.prove(i)
        rbc_send(peer, {:propose, h, b_i, elem(s, i)}, r)
      end)
    end
  end

  def recv({:rbc, sender, {:propose, h, b_i, s_i}, r} = msg) do
    # receive proposal from this sender.
    if not RBC.State.received_propose(sender, r) do
      if check_size(s_i) do
        # Wait until we get to round r - 1 locally.
        if MyDAG.max_round() < r - 1 do
          Process.sleep(1000)
          recv(msg)
        else
          N.debug("Received #{s_i}")
          # IO.puts("This is node #{inspect(self())}")
          # IO.inspect(s_i)
          multicast(N.peers, {:prevote, h, b_i, s_i}, r)
        end
      end
      RBC.State.mark_received_propose(sender, r)
    end
  end

  def recv({:rbc, sender, {:prevote, h, b_i, s_i}, r} = msg) do
    # record prevote
    RBC.State.prevote(h, b_i, s_i)
    # N.debug("Prevote from #{inspect(sender)}: #{inspect(s_i)}")

    parts = RBC.State.get(:prevote, h)
    # N.debug(parts)
    # TODO: wait until all U's parents are locally output by this node.
    # TODO: once we have erasure encoding, change this to ">= 2 * N.f + 1"
    if parts |> MapSet.size() == N.n do
      N.debug("Received N prevotes.")
      # Reconstruct U from the s parts.
      s = parts |> Enum.map(fn part -> part.s end)
      {chunks, unit} = Crypto.erasure_decode_with_chunks(s)

      # Check merkle tree
      mt_prime = chunks |> MerkleTree.new(default_data_block: "")
      h_prime = mt_prime.root.value

      if h == h_prime and not RBC.State.has_committed? do
        N.debug("Time to commit: #{inspect(unit)}")
        RBC.State.set(:commit, true)
        multicast(N.peers, {:commit, sender, h}, r)
      end
    end

  end

  # TODO: modify this module so that the original sender info is saved.
  # Currently the sender info doesn't reflect the original sender.
  def recv({:rbc, sender, {:commit, s, h}, r}) do
    RBC.State.increment(:commit, r, h)
    if RBC.State.get(:commit, r, h) == N.f + 1 do
      if not RBC.State.has_committed?() do
        N.debug("Time to commit.")
        RBC.State.set(:commit, true)
        multicast(N.peers, {:commit, s, h}, r)
      end
    end

    if RBC.State.get(:commit, r, h) >= 2 * N.f + 1 do

      unit = RBC.State.get(:prevote, h)
        |> Enum.map(& &1.s)
        |> Crypto.erasure_decode()
      # Before outputting, clear the RBC state.
      RBC.State.reset()
      __MODULE__.output({r, unit})
    end
  end

  def recv(anything) do
    IO.inspect(anything)
  end

  defp multicast(peers, message, r) do
    for p <- peers do
      rbc_send(p, message, r)
    end
  end

  # TODO: update this function to actually check size.
  defp check_size(_s_i) do
    true
  end

end
