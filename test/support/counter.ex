defmodule Counting do
  @moduledoc false

  use GenServer

  def start_link(initial) do
    GenServer.start_link(__MODULE__, initial)
  end

  def init(state) do
    {:ok, state}
  end

  def run do
    activate?()
  end

  def activate? do
    GenServer.cast(self(), :activate)
  end

  def local_state do
    GenServer.call(self(), :localstate)
  end

  def is_endpoint?(pids) do
    pids |> length |> Kernel.==(1)
  end

  def next_node(receiver, pids) do
    Enum.filter(pids, fn x -> x != receiver end)
  end

  def spread_the_word([], number), do: number

  def spread_the_word(nodes, number) do
    nodes
    |> Enum.each(fn n -> GenServer.cast(n, {:update, {self(), number}}) end)

    number
  end

  def handle_cast({:count, {receiver, delta}}, {count, pids}) do
    number = count + delta + 1

    updated =
      case count > 0 || is_endpoint?(pids) do
        true ->
          pids
          |> spread_the_word(number)
          |> IO.puts()

          number

        _ ->
          next = receiver |> next_node(pids)
          GenServer.cast(hd(next), {:count, {self(), delta + 1}})
          delta + 1
      end

    {:noreply, {number, pids}}
  end

  def handle_cast({:update, {receiver, number}}, {_, pids}) do
    receiver
    |> next_node(pids)
    |> spread_the_word(number)
    |> IO.puts()

    {:noreply, {number, pids}}
  end

  def handle_call(:localstate, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:set_node_list, pids}, state) do
    {:noreply, {state, pids}}
  end

  def handle_call(:neighbors, _, state = {_, pids}) do
    {:reply, pids, state}
  end

  def handle_cast(:activate, s = {_, pids}) do
    case is_endpoint?(pids) do
      true ->
        GenServer.cast(hd(pids), {:count, {self(), 1}})
        {:noreply, s}

      _ ->
        {:noreply, s}
    end
  end
end
