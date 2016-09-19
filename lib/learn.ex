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

    player_direction = random_direction(player)
    opponent_direction = random_direction(opponent)

    GenServer.cast(pid, {:turn, %{player_direction: player_direction,
                                  opponent_direction: opponent_direction,
                                  player_number: player_number,
                                  player: player,
                                  opponent: opponent}})

    {player_direction, opponent_direction}
  end

  def won(pid, player_number) do
    win = GenServer.call(pid, {:win, player_number})
    GenServer.stop(pid)

    win
  end

  def tied(pid) do
    GenServer.stop(pid)
  end

  defp random_direction(%{left: 0, right: _right}), do: :right
  defp random_direction(%{left: _left, right: 0}), do: :left
  defp random_direction(_player) do
    Enum.random([:left, :right])
  end

  # Sever
  def handle_cast({:turn, %{player_direction: player_direction,
                            opponent_direction: opponent_direction,
                            player_number: player_number,
                            player: player,
                            opponent: opponent}}, state) do
    record = %{
      player: normalize_player(player),
      opponent: normalize_player(opponent),
      from: player[player_direction],
      to: opponent[opponent_direction]
    }

    state = Map.update!(state, player_number, fn
       state -> [record | state]
    end)

    {:noreply, state}
  end

  def handle_call({:win, player_number}, _from, records) do
    {:reply, records[player_number], nil}
  end

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

  def play, do: play(10, [])

  def play(0, wins) do
    wins
    |> List.flatten
    |> Enum.reduce(%{}, fn
    %{
      player: player,
      opponent: opponent,
      from: from,
      to: to
    }, acc ->
        # Use these as keys for later lookup.
        game_state = {player, opponent}
        move = {from, to}

        # Each game state should have an array of moves, with a count of each move.
        Map.update(acc, game_state, %{move => 1}, fn moves ->
          Map.update(moves, move, 1, &(&1 + 1))
        end)
    end)
    |> throw
  end

  def play(i, wins) do
    {:ok, pid} = Generator.start_link

    winner = Engine.play(
      20,
      fn player_number, players -> Generator.take_turn(pid, player_number, players) end
    )

    case winner do
      0 ->
        Generator.tied(pid)
        # Ignore this iteration
        play(i, wins)
      winner ->
        win = Generator.won(pid, winner)
        play(i - 1, [win | wins])
    end
  end

end
