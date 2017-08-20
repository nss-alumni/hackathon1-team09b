defmodule NssTilWeb.TilController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  def get_tils(conn, _params) do
    """
    select
      id,
      text,
      upvote_count,
      downvote_count,
      user_id,
      created_at :: text
    from til.til
    """
    |> Db.query(to_json: true)
    |> Response.send_response(conn)
  end
end
