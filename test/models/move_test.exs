defmodule Chopsticks.MoveTest do
  use Chopsticks.ModelCase

  alias Chopsticks.Move

  @valid_attrs %{left: 42, right: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Move.changeset(%Move{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Move.changeset(%Move{}, @invalid_attrs)
    refute changeset.valid?
  end
end
