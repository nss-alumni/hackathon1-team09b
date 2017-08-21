defmodule NssTilWeb.Router do
  use NssTilWeb, :router

  alias NssTilWeb.Plugs

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

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug Plugs.Auth
  end

  scope "/", NssTilWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", NssTilWeb do
    pipe_through :api

    get "/tils", TilController, :get_tils
    get "/tils/:til_id/comments", CommentsController, :get_comments
    get "/search", SearchController, :search

    post "/slack_search", SearchController, :slack_search
    post "/slack_tils", TilController, :create_slack_til
  end

  scope "/api", NssTilWeb do
    pipe_through :auth_api

    post "/tils", TilController, :create_til
    post "/tils/:til_id/upvote", VoteController, :upvote_til
    post "/tils/:til_id/downvote", VoteController, :downvote_til
    post "/tils/:til_id/clearvote", VoteController, :clear_til_vote
    post "/tils/:til_id/comments", CommentsController, :create_comment

    get "/users/:user_id/votes", VoteController, :get_user_votes
  end
end
