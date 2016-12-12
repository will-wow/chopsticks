defmodule Chopsticks.GameState do
  defstruct [:players, :turns_left, :next_player, :winner, :error_code, :dumb]

  def decode(game_state) do
    game_state
    # TODO: This is some nonsense.
    |> Poison.encode!
    |> Poison.decode!(as: %Chopsticks.GameState{})
    |> Map.update!(:players, fn players ->
      %{1 => %{left: players["1"]["left"],
               right: players["1"]["right"]},
        2 => %{left: players["2"]["left"],
               right: players["2"]["right"]}}
    end)
    |> Map.delete(:error_code)
  end
end

