defmodule NssTilWeb.VoteController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  @upvote_value 1
  @downvote_value -1

  def upvote_til(conn, %{"til_id" => til_id}) do
    user_id = conn.assigns.user_id

    til_id
    |> String.to_integer
    |> vote(user_id, @upvote_value)
    |> Response.send_response(conn)
  end

  def downvote_til(conn, %{"til_id" => til_id}) do
    user_id = conn.assigns.user_id

    til_id
    |> String.to_integer
    |> vote(user_id, @downvote_value)
    |> Response.send_response(conn)
  end

  defp vote(til_id, user_id, value) do
    """
    insert into til.vote
      (til_id, user_id, value, modified_at) values
      ($1, $2, $3, now())
    on conflict (til_id, user_id) do update
      set value=EXCLUDED.value, modified_at = now()
    returning
      id,
      til_id,
      user_id,
      value
    """
    |> Db.query([til_id, user_id, value], to_json: true)
  end
end
