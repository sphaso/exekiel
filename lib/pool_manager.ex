defmodule Exekiel.PoolManager do
  @moduledoc false

  alias Exekiel.Graph
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(node_definition) do
    DynamicSupervisor.start_child(__MODULE__, node_definition)
  end

  def get_children do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(&elem(&1, 1))
  end

  def build_pool(lista, node_definition) do
    if Graph.graphical?(lista) do
      do_build_pool(lista, node_definition)
    else
      raise "graph provided is impossible"
    end
  end

  def do_build_pool(lista, {module, state}) do
    pids =
      lista
      |> Graph.build_graph()
      |> Enum.map(fn {i, adj} ->
        {:ok, pid} = start_child({module, state})
        {i, pid, adj}
      end)

    Enum.each(pids, fn {_, p, adj} ->
      adj_pids = Enum.map(adj, fn i -> find_pid(i, pids) end)
      GenServer.cast(p, {:set_node_list, adj_pids})
    end)
  end

  def run_on_each(command \\ :activate) do
    Enum.each(get_children(), fn p -> GenServer.cast(p, command) end)
  end

  def run_on_endpoint(command \\ :activate) do
    get_children()
    |> Enum.find(fn p ->
      p
      |> GenServer.call(:neighbors)
      |> length
      |> Kernel.==(1)
    end)
    |> GenServer.cast(command)
  end

  defp find_pid(i, pids) do
    {_, p, _} = Enum.find(pids, fn {y, _, _} -> y == i end)
    p
  end
end
