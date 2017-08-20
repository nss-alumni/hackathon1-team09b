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

  def create_comment(conn, %{
    "til_id" => til_id,
    "text" => text,
  }) do
    til_id = String.to_integer(til_id)
    user_id = conn.assigns.user_id

    """
    insert into til.comment
      (til_id, text, user_id) values
      ($1, $2, $3)
    returning
      id,
      text,
      til_id,
      user_id,
      created_at :: text
    """
    |> Db.query([til_id, text, user_id], to_json: true)
    |> Response.send_response(conn)
  end
end
