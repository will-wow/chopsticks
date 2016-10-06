defmodule Chopsticks.Router do
  use Chopsticks.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    # plug :accepts, ["json"]
  end

  scope "/", Chopsticks do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Chopsticks do
    pipe_through :api

    get "/play", GameController, :play
    post "/turn", GameController, :turn
  end

  # Other scopes may use custom stacks.
  # scope "/api", Chopsticks do
  #   pipe_through :api
  # end
end
