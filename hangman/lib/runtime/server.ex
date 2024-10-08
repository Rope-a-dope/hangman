defmodule Hangman.Runtime.Server do
  alias Hangman.Runtime.Watchdog
  alias Hangman.Impl.Game

  @type t :: pid

  # 1 hour
  @idle_timeout 1 * 60 * 60 * 1000
  @me __MODULE__

  use GenServer

  ### Client process
  def start_link(_) do
    GenServer.start_link(@me, nil)
  end

  ### Server process
  def init(_) do
    watcher = Watchdog.start(@idle_timeout)
    {:ok, {Game.new_game(), watcher}}
  end

  def handle_call({:make_move, guess}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {updated_game, tally} = Game.make_move(game, guess)
    {:reply, tally, {updated_game, watcher}}
  end

  def handle_call({:tally}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply, Game.tally(game), {game, watcher}}
  end
end
