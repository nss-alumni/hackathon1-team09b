defmodule NssTilWeb.Router do
  use NssTilWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NssTilWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", NssTilWeb do
    pipe_through :api

    get "/tils", TilController, :get_tils
    post "/tils", TilController, :create_til
  end
end
