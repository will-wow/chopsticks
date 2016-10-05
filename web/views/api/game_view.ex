defmodule Chopsticks.GameView do
  use Chopsticks.Web, :view

  def render("game_state.json", %{data: game_state}) do
    game_state
    # Translate the players map from {1 => player, 2 => opponent} to [player, opponent]
    |> Map.update!(:players, fn players ->
      [players[1], players[2]]
    end)
  end
end
