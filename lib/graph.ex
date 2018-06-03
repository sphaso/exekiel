defmodule Exekiel.Graph do
  @moduledoc false

  require Integer

  @doc """
  iex> #{__MODULE__}.build_graph([1, 1])
  [{0, Enum.into([1], MapSet.new)}, {1, Enum.into([0], MapSet.new)}]
  iex> #{__MODULE__}.build_graph([2, 1, 1])
  [{0, Enum.into([1, 2], MapSet.new)}, {1, Enum.into([0], MapSet.new)}, {2, Enum.into([0], MapSet.new)}]
  iex> #{__MODULE__}.build_graph([4, 4, 4, 3, 3])
  [{0, Enum.into([1, 2, 3, 4], MapSet.new)}, {1, Enum.into([0, 2, 3, 4], MapSet.new)}, {2, Enum.into([0, 1, 3, 4], MapSet.new)}, {3, Enum.into([0, 1, 2], MapSet.new)}, {4, Enum.into([0, 1, 2], MapSet.new)}]
  iex> #{__MODULE__}.build_graph([2, 2, 2, 2, 2])
  [{0, Enum.into([1, 2], MapSet.new)}, {3, Enum.into([1, 4], MapSet.new)}, {4, Enum.into([2, 3], MapSet.new)}, {2, Enum.into([0, 4], MapSet.new)}, {1, Enum.into([0, 3], MapSet.new)}]
  """
  def build_graph(lista) do
    indexed =
      lista
      |> Enum.with_index()
      |> Enum.map(fn {a, b} -> {a, b, MapSet.new()} end)

    do_build_graph(indexed, [])
  end

  defp do_build_graph([], acc), do: acc

  defp do_build_graph([{n, i, adj} | t], acc) do
    adjacent_nodes =
      t
      |> Enum.map(&elem(&1, 1))
      |> Enum.take(max(0, n - MapSet.size(adj)))
      |> MapSet.new()

    next =
      t
      |> Enum.map(fn {a, b, c} ->
        if MapSet.member?(adjacent_nodes, b) do
          {a, b, MapSet.put(c, i)}
        else
          {a, b, c}
        end
      end)
      |> Enum.sort_by(fn {_, _, c} -> MapSet.size(c) end)

    new_acc = acc ++ [{i, MapSet.union(adj, adjacent_nodes)}]

    do_build_graph(next, new_acc)
  end

  @doc """
  Havel-Hakimi algorithm

  iex> #{__MODULE__}.graphical?([3, 3, 3, 3])
  true
  iex> #{__MODULE__}.graphical?([2, 2, 2, 2, 2])
  true
  iex> #{__MODULE__}.graphical?([4,1])
  false
  iex> #{__MODULE__}.graphical?([7,7, 4, 3, 3, 3, 2, 1])
  false
  iex> #{__MODULE__}.graphical?([5, 4, 3, 3, 2, 2, 2, 1, 1, 1])
  true
  """
  def graphical?([]), do: true
  def graphical?([n]) when n != 0, do: false

  def graphical?(lista) do
    graphical_basic_heuristics(lista) && graphical?(remove_first_vertex(lista))
  end

  defp graphical_basic_heuristics(lista) do
    !odd_degree?(lista) && !too_high_degree?(lista)
  end

  defp remove_first_vertex([h | t]) do
    first_stub = Enum.take(t, h)
    second_stub = Enum.drop(t, h)
    reconstruct = Enum.map(first_stub, &(&1 - 1)) ++ second_stub

    reconstruct
    |> Enum.sort()
    |> Enum.reverse()
  end

  def max_degree(lista), do: Enum.max(lista)
  def min_degree(lista), do: Enum.min(lista)
  def node_count(lista), do: length(lista)

  defp too_high_degree?(lista) do
    max_degree(lista) > node_count(lista) - 1
  end

  defp odd_degree?(lista) do
    lista
    |> Enum.filter(&Integer.is_odd/1)
    |> length()
    |> Integer.is_odd()
  end
end
