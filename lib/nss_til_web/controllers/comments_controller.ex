defmodule NssTilWeb.CommentsController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  def get_comments(conn, %{"til_id" => til_id}) do
    til_id = String.to_integer(til_id)

    """
    select
      id,
      text,
      til_id,
      user_id,
      created_at :: text
    from til.comment
    where til_id = $1
    """
    |> Db.query([til_id], to_json: true)
    |> Response.send_response(conn)
  end
end
