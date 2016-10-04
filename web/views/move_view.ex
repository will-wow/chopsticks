defmodule Chopsticks.MoveView do
  use Chopsticks.Web, :view

  def render("index.json", %{moves: moves}) do
    %{data: render_many(moves, Chopsticks.MoveView, "move.json")}
  end

  def render("show.json", %{move: move}) do
    %{data: render_one(move, Chopsticks.MoveView, "move.json")}
  end

  def render("move.json", %{move: move}) do
    %{id: move.id,
      left: move.left,
      right: move.right}
  end
end
