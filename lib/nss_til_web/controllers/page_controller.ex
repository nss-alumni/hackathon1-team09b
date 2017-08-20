defmodule NssTilWeb.PageController do
  use NssTilWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
