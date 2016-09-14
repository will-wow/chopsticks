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

  def play do
    player = %{left: 1, right: 1}

    players = %{1 => player, 2 => player}

    winner = turn(
      1,
      players,
      &interactive_player_direction/2,
      &interactive_opponent_direction/2
    )

    IO.puts "Player #{winner} wins!"
  end

  def turn(player_number, players, get_player_direction, get_opponent_direction) do
    p1 = players[1]
    p2 = players[2]
    current_player = players[player_number]

    cond do
      lost?(p1) ->
        2
      lost?(p2) ->
        1
      true ->
        player_direction = get_player_direction.(player_number, players)
        opponent_direction = get_opponent_direction.(player_number, players)

        next_number = next_player_number(player_number)
        next_player = players[next_number]

        updated_players =
          %{}
          |> Map.put(player_number, current_player)
          |> Map.put(
            next_number,
            add_to_hand(next_player, opponent_direction, current_player[player_direction])
          )

        turn(next_number, updated_players, get_player_direction, get_opponent_direction)
    end
  end

  def next_player_number(1), do: 2
  def next_player_number(2), do: 1

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
