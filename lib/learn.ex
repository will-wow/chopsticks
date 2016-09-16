defmodule Numbers.Learn.Generator do
  @moduledoc """
  GenServer for generating and remembering moves.
  """

  use GenServer

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def take_turn(pid, player_number, players) do
    player = players[player_number]
    next_number = next_player_number(player_number)
    opponent = players[next_number]

    player_direction = random_direction
    opponent_direction = random_direction

    GenServer.cast(pid, {:turn, %{direction: player_direction,
                                  opponent_direction: opponent_direction,
                                  player: player,
                                  opponent: opponent}})

    {player_direction, opponent_direction}
  end

  def won(player_number) do
    GenServer.call(pid, :win, player_number)
  end

  def tied_or_lost(pid) do
    GenServer.stop(pid)
  end

  defp random_direction do
    Enum.random([:left, :right])
  end

  # Sever
  def handle_cast({:turn, %{direction: player_direction,
                            opponent_direction: opponent_direction,
                            player: player,
                            opponent: opponent}}) do
  end

  def handle_call(:win, _from, player_number) do
  end
end

defmodule Numbers.Learn do
  @moduledoc """
  Functions for learning how to play Chopsticks.
  """

  def test do
    GenServer
  end


end
