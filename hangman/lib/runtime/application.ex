defmodule Hangman.Runtime.Application do
  @super_name GameStarter

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: @super_name},
      {Hangman.Runtime.GameCounter, []} # Start GameCounter
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_game() do
    Hangman.Runtime.GameCounter.increment_game_count()
    DynamicSupervisor.start_child(@super_name, {Hangman.Runtime.Server, nil})
  end
end
