defmodule Chopsticks.Random do
  @moduledoc """
  Tools for randomly picking a valid move.
  """

  alias Chopsticks.Engine

  def random_move(player, opponent) do
    case random_move_type(player) do
      :split ->
        {:split, nil}
      :touch ->
        player_direction = random_direction(player)
        opponent_direction = random_direction(opponent)

        {:touch, {player_direction, opponent_direction}}
    end
  end

  def random_move_type(player) do
    case Engine.validate_split(player) do
      {:ok} -> Enum.random([:split, :touch])
      {:error, _code} -> :touch
    end
  end

  def random_direction(%{left: 0, right: _right}), do: :right
  def random_direction(%{left: _left, right: 0}), do: :left
  def random_direction(_player) do
    Enum.random([:left, :right])
  end
end
