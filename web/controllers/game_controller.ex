defmodule Chopsticks.GameController do
  use Chopsticks.Web, :controller
  alias Chopsticks.AiPlay
  alias Chopsticks.Engine

  def play(conn, _) do
		render conn, "game_state.json", data: Engine.starting_state(20)
  end
end
