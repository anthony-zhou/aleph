# defmodule DAG do
#   use Agent
#   @f 1
#   @n 4

#   # Data structure: List of sets, where each index is a round and each set is a set of nodes.

#   defp get_genesis_vertices() do
#     1..(2 * @f + 1)
#     |> Enum.map(fn _ -> :rand.uniform(100000) |> floor() |> Integer.to_string() end)
#     |> Enum.map(fn str -> :crypto.hash(:sha256, str) end)
#     |> Enum.map(fn hash ->
#       %Vertex{
#         round: 0,
#         source: nil,
#         block: hash,
#         strongEdges: [],
#         weakEdges: []
#       }
#     end)
#   end

#   def start_link() do
#     Agent.start_link(fn -> [get_genesis_vertices()] end, name: __MODULE__)
#   end

#   def get_latest_round() do
#     Agent.get(__MODULE__, & List.last(&1))
#   end

#   def construct_dag() do

#   end

# end
