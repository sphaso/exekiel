defmodule Exekiel.PoolTest do
  use ExUnit.Case
  doctest Exekiel.PoolManager

  alias Exekiel.PoolManager

  test "count algorithm" do
    PoolManager.build_pool([2, 1, 1], {Counting, 0})

    assert %{active: 3, specs: 3, supervisors: 0, workers: 3} =
             DynamicSupervisor.count_children(Exekiel.PoolManager)

    PoolManager.run_on_endpoint()

    PoolManager.get_children()
    |> Enum.map(fn p ->
      {n, _} = GenServer.call(p, :localstate)
      n
    end)
    |> Enum.at(2)
    |> Kernel.==(3)
    |> assert
  end
end
