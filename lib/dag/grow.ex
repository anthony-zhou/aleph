defmodule DAG.Grow do
  alias Driver.Node, as: N

   def create_unit(data) do
    r = MyDAG.next_round()
    # Wait until the local DAG has enough layers
    if r > 0 and MapSet.size(MyDAG.get_units_for_round(r-1)) < 2 * N.f + 1 do
      Process.sleep(1000)
      send(self(), {:create_unit, data})
    else
      N.debug(r)
      N.debug(MapSet.size(MyDAG.get_units_for_round(r-1)))
      parents = MyDAG.get_my_parents(r)
      unit = DAG.Unit.new(DAG.Creator.myself(), parents, data)
      MyDAG.local_add(r, unit)
      # Return data as tuple so this can be broadcast to other nodes
      {unit, r}
     end
   end

   def receive_unit(r, unit) do
     MyDAG.add(r, unit)
   end
end
