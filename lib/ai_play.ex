defmodule Chopsticks.AiPlay do
  @moduledoc """
  Play against the AI.
  """

  alias Chopsticks.Random
  alias Chopsticks.Learn
  alias Chopsticks.Engine
  alias Chopsticks.Play

  def play do
    learnings = Learn.learn
    IO.inspect(learnings)

    Engine.play(
      20,
      get_move: &Play.get_move/2,
      get_move_2: &(pick_move(learnings, &1, &2)),
      display_error: &Play.display_error/1
    )
  end

  def pick_move(learnings, player_number, players) do
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
        {:touch, convert_to_directions(move, player, opponent)}
      {:split, nil} ->
        {:split, nil}
    end
  end

  @doc """
  Take the frequencies of moves and turn them into a frequency table.
  """
  def split_out_moves(nil), do: [nil]
  def split_out_moves(candidates), do: split_out_moves(Map.to_list(candidates), [])
  def split_out_moves([], freq_table), do: freq_table
  def split_out_moves([{move, frequency} | candidates], freq_table) do
    freq_table = Range.new(1, frequency)
    |> Enum.reduce(freq_table, &([move | &1]))

    split_out_moves(candidates, freq_table)
  end

  def convert_to_directions([], player, opponent) do
    {
      Random.random_direction(player),
      Random.random_direction(opponent)
    }
  end

  def convert_to_directions(freq_table, player, opponent) do
    {player_value, opponent_value} = Enum.random(freq_table)

    {
      convert_to_direction(player_value, player),
      convert_to_direction(opponent_value, opponent)
    }
  end

  def convert_to_direction(value, player) do
    if player.left === value do
      :left
    else
      :right
    end
  end
end
