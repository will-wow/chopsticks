defmodule Chopsticks.PageController do
  use Chopsticks.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
