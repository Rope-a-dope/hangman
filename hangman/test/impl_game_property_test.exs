defmodule HangmanImplGamePropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Hangman.Impl.Game

  property "new_game creates a game with the correct initial state" do
    check all(
            word <- string(:ascii, min_length: 1),
            word != ""
          ) do
      game = Game.new_game(word)
      word_codepoints = String.codepoints(word)

      assert %Game{
               turns_left: 7,
               game_state: :initializing,
               letters: ^word_codepoints,
               used: %MapSet{}
             } = game
    end
  end

  property "guessing a letter correctly or incorrectly changes game state appropriately" do
    check all(
            word <- string(:ascii, min_length: 1),
            word != ""
          ) do
      game = Game.new_game(word)
      good_guess = word |> String.codepoints() |> Enum.random()

      bad_guess =
        ?a..?z
        |> Enum.map(&<<&1>>)
        |> Enum.filter(&(!String.contains?(word, &1)))
        |> Enum.random()

      {game_after_good_guess, _} = Game.make_move(game, good_guess)
      assert game_after_good_guess.game_state in [:good_guess, :won]

      {game_after_bad_guess, _} = Game.make_move(game, bad_guess)
      assert game_after_bad_guess.turns_left == game.turns_left - 1
      assert game_after_bad_guess.game_state == :bad_guess
    end
  end

  property "repeated guesses do not decrease turns_left" do
    check all(
            word <- string(:ascii, min_length: 2),
            word != ""
          ) do
      game = Game.new_game(word)
      guess = word |> String.codepoints() |> Enum.random()

      {game, _} = Game.make_move(game, guess)
      {game_after_repeated_guess, _} = Game.make_move(game, guess)

      assert game_after_repeated_guess.turns_left == game.turns_left
      assert game_after_repeated_guess.game_state == :already_used
    end
  end

  property "game is lost when all turns are exhausted with wrong guesses" do
    check all(
            word <- string(:ascii, min_length: 1),
            word != ""
          ) do
      game = Game.new_game(word)

      bad_guesses =
        ?a..?z
        |> Enum.map(&<<&1>>)
        |> Enum.filter(&(!String.contains?(word, &1)))

      game =
        Enum.take_random(bad_guesses, 7)
        |> Enum.reduce(game, fn bad_guess, acc_game ->
          {new_game, _} = Game.make_move(acc_game, bad_guess)
          new_game
        end)

      assert game.game_state == :lost
      assert game.turns_left == 0
    end
  end

  property "guessing all letters correctly results in a win" do
    check all(
            word <- string(:ascii, min_length: 1),
            word != ""
          ) do
      game = Game.new_game(word)

      game =
        String.codepoints(word)
        |> Enum.reduce(game, fn letter, acc_game ->
          {new_game, _} = Game.make_move(acc_game, letter)
          new_game
        end)

      assert game.game_state == :won
    end
  end
end
