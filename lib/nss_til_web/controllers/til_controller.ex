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

  def create_til(conn, %{
    "text" => text
  }) do
    user_id = 1

    """
    insert into til.til
      (text, user_id) values
      ($1, $2)
    returning
      id,
      text,
      upvote_count,
      downvote_count,
      user_id,
      created_at :: text
    """
    |> Db.query([text, user_id], to_json: true)
    |> Response.send_response(conn)
  end
end
