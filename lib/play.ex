defmodule Chopsticks.Play do
  alias Chopsticks.Engine

  def play do
    winner = Engine.play(
      20,
      get_move: &get_move/2,
      display_error: &display_error/1
    )

    case winner do
      0 -> IO.puts "Tie game!"
      winner -> IO.puts "Player #{winner} wins!"
    end
  end

  def get_move(player_number, players) do
    p1 = players[1]
    p2 = players[2]

    IO.puts "Player 1: \n" <> render_hands(p1)
    IO.puts "Player 2: \n" <> render_hands(p2)

    IO.puts "Your move player #{player_number}"

    case String.trim(IO.gets "Do you want to touch, split, or quit? ") do
      "touch" ->
        player_direction = IO.gets "Your hand? "
        opponent_direction = IO.gets "Opponent hand? "

        {:touch, {convert_direction(player_direction), convert_direction(opponent_direction)}}
      "split" ->
        {:split, nil}
      "quit" ->
        {:quit, nil}
      bad ->
        IO.puts "bad"
        IO.puts bad
        {:bad, nil}
    end
  end

  def display_error(:unknown_move_type), do: IO.puts("I'm not sure what you want to do.")
  def display_error(:empty_player_hand), do: IO.puts("You can't pass from an empty hand.")
  def display_error(:empty_opponent_hand), do: IO.puts("You can't touch an empty hand.")
  def display_error(:no_empty_hand), do: IO.puts("You can only split when one had is empty.")
  def display_error(:no_even_hand), do: IO.puts("You can only split from an even hand.")

  def convert_direction(direction) do
    direction = String.trim(direction)

    direction = case direction do
      "l" -> "left"
      "r" -> "right"
      direction -> direction
    end

    String.to_atom(direction)
  end

  def render_hands(player) do
    """
#{render_hand(:left, player.left)}   #{render_hand(:right, player.right)}
_____   _____
    """
  end

  def render_hand(_, 0), do: "ooooo"
  def render_hand(_, 5), do: "|||||"
  def render_hand(direction, hand) do
    up = String.duplicate("|", hand)
    down = String.duplicate("o", 4 - hand)

    left_hand = down <> up <> "o"

    case direction do
      :left -> left_hand
      :right -> String.reverse(left_hand)
    end
  end
end
