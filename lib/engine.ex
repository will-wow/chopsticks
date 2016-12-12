require IEx

defmodule Chopsticks.Engine do
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

  @player %{left: 1, right: 1}
  @players %{1 => @player, 2 => @player}

  @doc """
  Take a single turn, returning the new game state.
  """
  def turn(%{players: players, turns_left: turns_left, next_player: player_number, dumb: dumb}, move) do
    case update_players(player_number, players, move) do
      {:ok, players} ->
        # If there was a move, check if it finished the game.
        case check_for_win(players) do
          0 ->
            if turns_left === 1 do
              {:done, %{players: players,
                        winner: 0,
                        turns_left: 0,
                        dumb: dumb}}
            else
              {:ok, %{players: players,
                      turns_left: turns_left - 1,
                      next_player: next_player_number(player_number),
                      dumb: dumb}}
            end
          winner ->
            {:done, %{players: players,
                      winner: winner,
                      turns_left: turns_left - 1,
                      dumb: dumb}}
        end
      {:quit, players, winner} ->
        {:done, %{players: players,
                  winner: winner,
                  turns_left: turns_left,
                  dumb: dumb}}
      {:error, players, code} ->
        {:error, %{players: players,
                   error_code: code,
                   next_player: player_number,
                   turns_left: turns_left,
                   dumb: dumb}}
    end
  end

  def starting_state(turns, dumb \\ false) do
    %{turns_left: turns, next_player: 1, players: @players, dumb: dumb}
  end

  @doc """
  Play a game of Chopsticks, passing in the number of turns and function to get the move.
  """
  def play(turns, callbacks) do
    get_move = callbacks[:get_move]
    get_move_2 = callbacks[:get_move_2] || callbacks[:get_move]
    display_error = callbacks[:display_error] || fn _ -> nil end

    play_turn(
      starting_state(turns),
      get_move,
      get_move_2,
      display_error
    )
  end

  # A recursive turn.
  defp play_turn(
    %{next_player: player_number, players: players} = game_state,
    get_move,
    get_move_2,
    display_error
  ) do
    move = get_move.(player_number, players)

    case turn(game_state, move) do
      {:ok, game_state} ->
        play_turn(game_state, get_move_2, get_move, display_error)
      {:error, %{error_code: error_code} = game_state} ->
        # For errors, display the error, then re-run the turn.
        display_error.(error_code)
        play_turn(game_state, get_move, get_move_2, display_error)
      {:done, %{winner: winner}} ->
        # For a finished game, just return.
        winner
    end
  end

  def update_players(player_number, players, {type, move}) do
    player = players[player_number]
    opponent_number = next_player_number(player_number)
    opponent = players[opponent_number]
    result =
      case type do
        :quit ->
          # When a player quits, the other player wins.
          {:quit}
        :touch ->
          touch_turn(player, opponent, move)
        :split ->
          split_turn(player, opponent)
        unknown_type ->
          IO.puts "unknown_type"
          IO.puts unknown_type
          {:error, :unknown_move_type}
      end

    case result do
      {:error, code} ->
        {:error, players, code}
      {:ok, player, opponent} ->
        updated_players =
          %{}
          |> Map.put(player_number, player)
          |> Map.put(opponent_number, opponent)

        {:ok, updated_players}
      {:quit} ->
        {:quit, players, opponent_number}
    end
  end

  def touch_turn(player, opponent, {player_direction, opponent_direction}) do
    case validate_touch(player, opponent, player_direction, opponent_direction) do
      {:error, code} ->
        {:error, code}
      {:ok} ->
        {
          :ok,
          player,
          add_to_hand(opponent, opponent_direction, player[player_direction])
        }
    end
  end

  def split_turn(player, opponent) do
    case validate_split(player) do
      {:error, code} ->
        {:error, code}
      {:ok} ->
        {:ok, split(player), opponent}
    end
  end

  def validate_touch(player, opponent, player_direction, opponent_direction) do
    cond do
      player[player_direction] === 0 -> {:error, :empty_player_hand}
      opponent[opponent_direction] === 0 -> {:error, :empty_opponent_hand}
      true -> {:ok}
    end
  end

  def validate_split(player) do
    cond do
      !(empty_hand?(player.left) || empty_hand?(player.right)) -> {:error, :no_empty_hand}
      !(splitable_hand?(player.left) || splitable_hand?(player.right)) -> {:error, :no_even_hand}
      true -> {:ok}
    end
  end

  def empty_hand?(0), do: true
  def empty_hand?(_), do: false

  def splitable_hand?(0), do: false
  def splitable_hand?(hand) do
    rem(hand, 2) === 0
  end

  def split(player) do
    {_, hand} = Enum.find(player, fn {_, hand} -> splitable_hand?(hand) end)
    %{left: split_hand(hand), right: split_hand(hand)}
  end

  def split_hand(hand), do: round(hand / 2)

  def next_player_number(1), do: 2
  def next_player_number(2), do: 1

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

  def check_for_win(players) do
    cond do
      lost?(players[1]) -> 2
      lost?(players[2]) -> 1
      true -> 0
    end
  end

  def lost?(player) do
    player.left === 0 && player.right === 0
  end
end
