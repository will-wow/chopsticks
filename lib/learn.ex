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

    player_direction = random_direction
    opponent_direction = random_direction

    GenServer.cast(pid, {:turn, %{player_direction: player_direction,
                                  opponent_direction: opponent_direction,
                                  player_number: player_number,
                                  player: player,
                                  opponent: opponent}})

    {player_direction, opponent_direction}
  end

  def won(pid, player_number) do
    last_count = GenServer.call(pid, {:win, player_number})
    GenServer.stop(pid)

    last_count
  end

  def tied(pid) do
    GenServer.stop(pid)
  end

  defp random_direction do
    Enum.random([:left, :right])
  end

  # Sever
  def handle_cast({:turn, %{player_number: player_number} = data}, state) do
    # Don't double store the player_number
    record = Map.delete(data, :player_number)

    state = Map.update!(state, player_number, fn
       state -> [record | state]
    end)

    {:noreply, state}
  end

  def handle_call({:win, player_number}, _from, records) do
    {:reply, length(records[player_number]), records}
    # Because puts isn't doing what I want
    throw {:count, length(records[player_number])}
  end
end

defmodule Numbers.Learn do
  @moduledoc """
  Functions for learning how to play Chopsticks.
  """

  alias Numbers.Engine
  alias Numbers.Learn.Generator

  def play do
    {:ok, pid} = Generator.start_link

    winner = Engine.play(
      20,
      fn player_number, players -> Generator.take_turn(pid, player_number, players) end
    )

    case winner do
      0 ->
        Generator.tied(pid)
        play
      winner ->
        turn_count = Generator.won(pid, winner)
        IO.puts "Player #{winner} wins, with #{turn_count} moves!"
    end
  end

end
