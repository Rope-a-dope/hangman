defmodule Hangman.Runtime.GameCounter do
  use GenServer
  @me __MODULE__

  ### Client API
  def start_link(_) do
    GenServer.start_link(@me, %{game_count: 0, nodes: %{}}, name: @me)
  end

  def increment_game_count do
    GenServer.cast(@me, :increment_game_count)
  end

  ### Server Callbacks
  def init(state) do
    # Start monitoring nodes
    schedule_node_check()
    {:ok, state}
  end

  defp schedule_node_check() do
    Process.send_after(self(), :monitor_nodes, 3_000)
  end

  def handle_cast(:increment_game_count, state) do
    new_state = %{state | game_count: state.game_count + 1}

    [:green, "New game created.", :yellow, "Total games: #{new_state.game_count}"]
    |> IO.ANSI.format()
    |> IO.puts()

    {:noreply, new_state}
  end

  def handle_info(:monitor_nodes, state) do
    current_nodes = Node.list()

    new_nodes =
      current_nodes
      |> Enum.reduce(%{}, fn node, acc -> Map.put(acc, node, true) end)

    disconnected_nodes = Map.keys(state.nodes) -- current_nodes
    connected_nodes = current_nodes -- Map.keys(state.nodes)

    Enum.each(disconnected_nodes, fn node ->
      [:red, "Node disconnected: ", :yellow, "#{node}"] |> IO.ANSI.format() |> IO.puts()
    end)

    Enum.each(connected_nodes, fn node ->
      [:green, "Node connected: ", :yellow, "#{node}"] |> IO.ANSI.format() |> IO.puts()
    end)

    label = [:yellow, "Current nodes"] |> IO.ANSI.format()
    formatted_value = [:green, "#{inspect(new_nodes)}"] |> IO.ANSI.format()

    IO.puts("#{label}: #{formatted_value}")

    schedule_node_check()

    {:noreply, %{state | nodes: new_nodes}}
  end
end
