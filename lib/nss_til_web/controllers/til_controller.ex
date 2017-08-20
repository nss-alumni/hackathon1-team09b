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
        sum(case when value != 0 then 1 else 0 end) vote_count,
        sum(value) score
      from til.vote
      group by til_id
    )
    select
      t.id,
      t.text,
      v.upvote_count,
      v.downvote_count,
      v.vote_count,
      coalesce(v.score, 0) score,
      t.user_id,
      t.created_at :: text,
      u.name user_name,
      u.image_url user_image
    from til.til t
    left
    join vote v
      on v.til_id = t.id
    join til.user u
      on t.user_id = u.id
    order by score desc, created_at desc
    """
    |> Db.query(to_json: true)
    |> Response.send_response(conn)
  end

  def create_til(conn, %{
    "text" => text
  }) do
    user_id = conn.assigns.user_id

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
