defmodule NssTilWeb.VoteController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  @upvote_value 1
  @downvote_value -1
  @clear_value 0

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

  def clear_til_vote(conn, %{"til_id" => til_id}) do
    user_id = conn.assigns.user_id

    til_id
    |> String.to_integer
    |> vote(user_id, @clear_value)
    |> Response.send_response(conn)
  end

  def get_user_votes(conn, %{"user_id" => user_id}) do
    user_id = String.to_integer(user_id)

    """
    select
      v.til_id,
      v.user_id,
      v.value
    from til.vote v
    where v.user_id = $1
    """
    |> Db.query([user_id], to_json: true)
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
