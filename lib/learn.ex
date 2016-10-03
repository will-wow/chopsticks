defmodule Numbers.Learn.Generator do
  @moduledoc """
  GenServer for generating and remembering moves.
  """

  use GenServer
  alias Numbers.Engine

  # Client

  def start_link do
    GenServer.start_link(__MODULE__, %{1 => [], 2 => []})
  end

  def take_turn(pid, player_number, players) do
    player = players[player_number]
    next_number = Engine.next_player_number(player_number)
    opponent = players[next_number]

    {type, data} = move = random_move(player, opponent)

    case type do
      :split ->
        GenServer.cast(pid, {:turn, %{type: :split,
                                      player_number: player_number,
                                      player: player,
                                      opponent: opponent}})
      :touch ->
        {player_direction, opponent_direction} = data

        GenServer.cast(pid, {:turn, %{type: :touch,
                                      player_direction: player_direction,
                                      opponent_direction: opponent_direction,
                                      player_number: player_number,
                                      player: player,
                                      opponent: opponent}})
    end

    move
  end

  def won(pid, player_number) do
    win = GenServer.call(pid, {:win, player_number})
    GenServer.stop(pid)

    win
  end

  def tied(pid) do
    GenServer.stop(pid)
  end

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

  defp random_move_type(player) do
    case Engine.validate_split(player) do
      {:ok} -> Enum.random([:split, :touch])
      {:error, _code} -> :touch
    end
  end

  defp random_direction(%{left: 0, right: _right}), do: :right
  defp random_direction(%{left: _left, right: 0}), do: :left
  defp random_direction(_player) do
    Enum.random([:left, :right])
  end

  # Sever
  def handle_cast({:turn, %{type: type,
                            player_number: player_number,
                            player: player,
                            opponent: opponent} = data}, state) do

    move =
      case type do
        :touch ->
          %{
            from: player[data.player_direction],
            to: opponent[data.opponent_direction]
          }
        :split ->
          nil
      end

    record = %{
      type: type,
      player: normalize_player(player),
      opponent: normalize_player(opponent),
      move: move
    }

    state = Map.update!(state, player_number, fn
       state -> [record | state]
    end)

    {:noreply, state}
  end

  def handle_call({:win, player_number}, _from, records) do
    {:reply, records[player_number], nil}
  end

  # Normalizes a player map to be a list of the two hands, in value order.
  defp normalize_player(player) do
    player
    |> Map.values
    |> Enum.sort
    |> List.to_tuple
  end
end

defmodule Numbers.Learn do
  @moduledoc """
  Functions for learning how to play Chopsticks.
  """

  alias Numbers.Engine
  alias Numbers.Learn.Generator

  @doc """
  Learn from playing some random trials.
  """
  def learn, do: learn(10, [])

  def learn(0, wins) do
    wins
    |> List.flatten
    |> Enum.reduce(%{}, fn
      %{
        type: type,
        player: player,
        opponent: opponent,
        move: move_data
      }, acc ->
        # Use these as keys for later lookup.
        game_state = {player, opponent}
        move = {type, move_data}

        # Each game state should have an array of moves, with a count of each move.
        Map.update(acc, game_state, %{move => 1}, fn moves ->
          Map.update(moves, move, 1, &(&1 + 1))
        end)
    end)
  end

  def learn(i, wins) do
    {:ok, pid} = Generator.start_link

    winner = Engine.play(
      20,
      get_move: fn player_number, players ->
        Generator.take_turn(pid, player_number, players)
      end,
      display_error: fn code ->
        raise code
      end
    )

    case winner do
      0 ->
        Generator.tied(pid)
        # Ignore this iteration
        learn(i, wins)
      winner ->
        win = Generator.won(pid, winner)
        learn(i - 1, [win | wins])
    end
  end

end
