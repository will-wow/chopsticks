defmodule Numbers.Play do
  alias Numbers.Engine

  def play do
    player = %{left: 1, right: 1}

    players = %{1 => player, 2 => player}

    winner = Engine.turn(
      1,
      players,
      &interactive_player_direction/2,
      &interactive_opponent_direction/2
    )

    IO.puts "Player #{winner} wins!"
  end

  def interactive_player_direction(player_number, players) do
    p1 = players[1]
    p2 = players[2]

    IO.puts "Player 1: \n" <> render_hands(p1)
    IO.puts "Player 2: \n" <> render_hands(p2)

    IO.puts "Your move player #{player_number}"
    player_direction = IO.gets "Your hand? "

    convert_direction(player_direction)
  end

  def interactive_opponent_direction(_player_number, _players) do
    opponent_direction = IO.gets "Opponent hand? "

    convert_direction(opponent_direction)
  end

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
