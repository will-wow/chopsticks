defmodule Chopsticks.MoveControllerTest do
  use Chopsticks.ConnCase

  alias Chopsticks.Move
  @valid_attrs %{left: 42, right: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, move_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    move = Repo.insert! %Move{}
    conn = get conn, move_path(conn, :show, move)
    assert json_response(conn, 200)["data"] == %{"id" => move.id,
      "left" => move.left,
      "right" => move.right}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, move_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, move_path(conn, :create), move: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Move, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, move_path(conn, :create), move: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    move = Repo.insert! %Move{}
    conn = put conn, move_path(conn, :update, move), move: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Move, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    move = Repo.insert! %Move{}
    conn = put conn, move_path(conn, :update, move), move: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    move = Repo.insert! %Move{}
    conn = delete conn, move_path(conn, :delete, move)
    assert response(conn, 204)
    refute Repo.get(Move, move.id)
  end
end
