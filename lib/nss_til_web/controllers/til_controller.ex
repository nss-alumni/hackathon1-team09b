defmodule NssTilWeb.TilController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  def get_tils(conn, _params) do
    """
    with vote as (
      select
        til_id,
        sum(case when value > 0 then 1 else 0 end) upvote_count,
        sum(case when value < 0 then 1 else 0 end) downvote_count,
        sum(case when value != 0 then 1 else 0 end) vote_count
      from til.vote
      group by til_id
    )
    select
      t.id,
      t.text,
      v.upvote_count,
      v.downvote_count,
      v.vote_count,
      t.user_id,
      t.created_at :: text
    from til.til t
    left
    join vote v
      on v.til_id = t.id
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
      user_id,
      created_at :: text
    """
    |> Db.query([text, user_id], to_json: true)
    |> Response.send_response(conn)
  end
end
