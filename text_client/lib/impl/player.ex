defmodule TextClient.Impl.Player do
  @type game :: Hangman.game()
  @type tally :: Hangman.tally()
  @type state :: {game, tally}

  @spec start(game) :: :ok
  def start(game) do
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  def interact({_game, tally = %{game_state: :won}}) do
    [
      :green,
      "Congratulations. You won! You gueesed the word: ",
      :yellow,
      "#{tally.letters |> Enum.join()}"
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  def interact({_game, tally = %{game_state: :lost}}) do
    [
      :red,
      "Sorry, you lost ... the word was ",
      :green,
      "#{tally.letters |> Enum.join()}"
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  @spec interact(state) :: :ok
  def interact({game, tally}) do
    tally |> feedback_for() |> IO.puts()
    tally |> current_word() |> IO.puts()

    tally = Hangman.make_move(game, get_guess())
    interact({game, tally})
  end

  def feedback_for(tally = %{game_state: :initializing}) do
    "Welcome! I'm thinking of a #{tally.letters |> length} letter word"
  end

  def feedback_for(%{game_state: :good_guess}), do: "Good guess!"
  def feedback_for(%{game_state: :bad_guess}), do: "Sorry, that letter is not in the word"
  def feedback_for(%{game_state: :already_used}), do: "You already used that letter"

  def current_word(tally) do
    [
      :yellow,
      "Word so far:  ",
      :green,
      tally.letters |> Enum.join(" "),
      :yellow,
      " turns left:  ",
      :green,
      tally.turns_left |> to_string(),
      :yellow,
      " used so far: ",
      :green,
      tally.used |> Enum.join(",")
    ]
    |> IO.ANSI.format()
  end

  def get_guess() do
    IO.gets("Next letter: ")
    |> String.trim()
    |> String.downcase()
  end
end
