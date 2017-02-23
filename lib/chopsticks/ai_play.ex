defmodule Chopsticks.AiPlay do
  @moduledoc """
  Play against the AI.
  """

  alias Chopsticks.Random
  alias Chopsticks.Learn
  alias Chopsticks.Engine
  alias Chopsticks.Play

  @doc """
  Kick off a game with the AI.
  """
  def play do
    learnings = Learn.learn

    winner = Engine.play(
      20,
      get_move: &Play.get_move/2,
      get_move_2: fn player_number, players ->
        pick_move(
          %{next_player: player_number,
            players: players},
          learnings
        )
      end,
      display_error: &Play.display_error/1
    )

    case winner do
      0 -> IO.puts "Tie game!"
      1 -> IO.puts "You beat the robot! Humanity is safe. For now."
      2 -> IO.puts "The robot beat you! The age of humanity draws to a close."
    end
  end

  def pick_move(
    %{next_player: player_number,
      players: players},
    learnings
  ) do
    player = players[player_number]
    next_number = Engine.next_player_number(player_number)
    opponent = players[next_number]

    move =
      learnings[{player, opponent}]
      |> split_out_moves
      |> Enum.random

    case move do
      nil ->
        Random.random_move(player, opponent)
      {:touch, move} ->
        {:touch, pick_move(move, player, opponent)}
      {:split, nil} ->
        {:split, nil}
    end
  end

  @doc """
  take the frequencies of moves and turn them into a frequency table.
  """
  def split_out_moves(nil), do: [nil]
  def split_out_moves(candidates), do: split_out_moves(Map.to_list(candidates), [])
  def split_out_moves([], freq_table), do: freq_table
  def split_out_moves([{move, frequency} | candidates], freq_table) do
    freq_table = Range.new(1, frequency)
    |> Enum.reduce(freq_table, &([move | &1]))

    split_out_moves(candidates, freq_table)
  end


  @doc """
  Pick a move from the frequency table.
  """
  def pick_move([], player, opponent) do
    # Pick a ranom move if there's nothing in the learnings.
    {
      Random.random_direction(player),
      Random.random_direction(opponent)
    }
  end

  def pick_move(freq_table, player, opponent) do
    {player_value, opponent_value} = Enum.random(freq_table)

    {
      convert_to_direction(player_value, player),
      convert_to_direction(opponent_value, opponent)
    }
  end

  @doc """
  Convert a recorded move to a direction for the current situation.
  """
  def convert_to_direction(value, player) do
    if player.left === value do
      :left
    else
      :right
    end
  end
end
