defmodule DAG.Grow do
   def create_unit(data) do
     r = MyDAG.next_round()
     # Wait until the local DAG has enough layers
    #  if r > 0 and MyDAG.get_units_for_round(r-1) |> MapSet.size() do
    #   Process.sleep(1000)
    #   create_unit(data)
    #  else

    parents = MyDAG.get_my_parents(r)
    unit = DAG.Unit.new(DAG.Creator.myself(), parents, data)
    MyDAG.add(r, unit)
    # Return data as tuple so this can be broadcast to other nodes
    {unit, r}
    #  end
   end

   def receive_unit(r, unit) do
     MyDAG.add(r, unit)
   end
end
