require IEx

defmodule Numbers do
  @moduledoc """
  Functions for playing the numbers hand game.

  Rules:
  Each player starts with 1 of 5 possible fingers up on each hand.
  On each turn, one player gives the number of up fingers on one hand to one of the other player's hands.
  If a hand has exactly 5 fingers up, all are knocked down.
  If a hand plus the given fingers is more than 5, the new number is old + added mod 5
  If a player has an even number of fingers on one hand, and no fingers on the other hand,
  they may use their turn to split their fingers evenly.
  The goal is to knock both the other player's hands to 0.
  """

  defmodule Player do
    defstruct left: 1, right: 1
  end

  def play do
    player_1 = %{left: 1, right: 1}
    player_2 = %{left: 1, right: 1}

    turn(1, player_1, player_2)
  end

  def turn(player, p1, p2) do
    cond do
      lost?(p1) ->
        IO.puts "Player 2 wins!"
      lost?(p2) ->
        IO.puts "Player 1 wins!"
      true ->
        IO.puts "Player 1: \n" <> render_hands(p1)
        IO.puts "Player 2: \n" <> render_hands(p2)

        IO.puts "Your move player #{player}"
        player_direction = IO.gets "Your hand? "
        opponent_direction = IO.gets "Opponent hand? "

        player_direction = convert_direction(player_direction)
        opponent_direction = convert_direction(opponent_direction)

        case player do
          1 -> turn(2, p1, add_to_hand(p2, opponent_direction, p1[player_direction]))
          2 -> turn(1, add_to_hand(p1, opponent_direction, p2[player_direction]), p2)
        end
    end
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

  def add_to_hand(player, direction, add_count) do
    {_, player} = Map.get_and_update!(player, direction, fn
      hand_count ->
        {hand_count, add_fingers(hand_count, add_count)}
    end)

    player
  end

  def add_fingers(hand_count, add_count) do
    new_count = hand_count + add_count

    cond do
      new_count > 5 -> new_count - 5
      new_count === 5 -> 0
      true -> new_count
    end
  end

  def lost?(player) do
    player.left === 0 && player.right === 0
  end
end
