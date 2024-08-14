defmodule B1Web.HangmanHTML do
  use B1Web, :html

  @moduledoc """
  This module contains pages rendered by HangmanController.

  See the `hangman_html` directory for all templates available.
  """

  embed_templates "hangman_html/*"

  @status_fields %{
    initializing: {"initializing", "Guess the word, a letter at a time"},
    good_guess: {"good-guess", "Good guess!"},
    bad_guess: {"bad-guess", "Sorry, that's a bad guess"},
    won: {"won", "You won!"},
    lost: {"lost", "Sorry, you lost"},
    already_used: {"already-used", "You already used that letter"}
  }

  def continue_or_try_again(assigns) do
    ~H"""
    <%= if @status in [:won, :lost] do %>
      <.form for={%{}} action={~p"/hangman"} method="post">
        <.button type="submit" class="button">
          Try again
        </.button>
      </.form>
    <% else %>
      <.form for={@form} action={~p"/hangman"} method="put" as={:make_move}>
        <.input field={@form[:guess]} type="text" required pattern="[a-z]" />
        <.button type="submit">Make new guess</.button>
      </.form>
    <% end %>
    """
  end

  def move_status(status) do
    {class, msg} = @status_fields[status]

    assigns = %{
      class: class,
      msg: msg
    }

    ~H"""
    <div class={"status #{@class}"}>
      <%= @msg %>
    </div>
    """
  end

  defdelegate figure_for(input), to: B1Web.HangmanHelpers.FigureFor
end
