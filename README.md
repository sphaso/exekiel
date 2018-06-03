# exekiel
Run arbitrary code on arbitrary graphs!

Given a degree sequence and a GenServer, Exekiel:
- does an initial check to see if the sequence is graphical (Havel-Hakimi algorithm)
- builds the undirected, unlabeled graph
- adds each vertex to a `DynamicSupervisor` (`PoolManager`)
- sends to each vertex its adjacency list of pids (see below: `:set_node_list`)
- can run arbitrary on one or all nodes of the graph

Please add 

```
  def handle_call(:localstate, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_node_list, pids}, state) do
    {:noreply, {state, pids}}
  end
```

to your GenServer.

![alt exekiel](https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Ezekiel_by_Michelangelo%2C_restored_-_large.jpg/1200px-Ezekiel_by_Michelangelo%2C_restored_-_large.jpg)
