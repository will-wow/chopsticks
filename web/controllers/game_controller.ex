defmodule Chopsticks.GameController do
  use Chopsticks.Web, :controller
  alias Chopsticks.AiPlay
  alias Chopsticks.Engine
  alias Chopsticks.Learn
  alias Chopsticks.Move
  alias Chopsticks.GameState

  def play(conn, _) do
    render_state(conn, Engine.starting_state(20))
  end

  def turn(conn, %{"move" => move, "game_state" => game_state}) do
    move = Move.decode(move)
    game_state = GameState.decode(game_state)

    new_state = Engine.turn(game_state, move)

    case new_state do
      {:ok, state} ->
        ai_move(conn, state)
      {:error, state} ->
        render_state(conn, state, 400)
      {:done, state} ->
        render_state(conn, state)
    end
  end

  def ai_move(conn, game_state) do
    learnings = Learn.learn
    IO.inspect(game_state)
    ai_move = AiPlay.pick_move(game_state, learnings)
    new_state = Engine.turn(game_state, ai_move)
    
    case new_state do
      {:error, state} ->
        render_state(conn, state, 400)
      {_code, state} ->
        render_state(conn, state)
    end
  end

  defp render_state(conn, game_state, status \\ 200) do
    conn
    |> put_status(status)
    |> render("game_state.json", data: game_state)
  end

end
