defmodule NssTilWeb.SearchController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  def search(conn, params) do
    query = params["q"]

    """
    with search as (
      select
        t.id til_id,
        ts_rank(to_tsvector(t.text), plainto_tsquery('english', $1))
          + similarity(t.text, $1) rank
      from til.til t
    ),
    vote as (
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
      u.image_url user_image,
      s.rank
    from til.til t
    left
    join vote v
      on v.til_id = t.id
    join til.user u
      on t.user_id = u.id
    join search s
      on s.til_id = t.id
    order by rank desc, score desc, created_at desc
    """
    |> Db.query([query], to_json: true)
    |> Response.send_response(conn)
  end

  def slack_search(conn, params) do
    query = params["text"]

    """
    with search as (
      select
        t.id til_id,
        ts_rank(to_tsvector(t.text), plainto_tsquery('english', $1))
          + similarity(t.text, $1) rank
      from til.til t
    ),
    vote as (
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
      t.text
    from til.til t
    left
    join vote v
      on v.til_id = t.id
    join til.user u
      on t.user_id = u.id
    join search s
      on s.til_id = t.id
    order by rank desc, score desc, t.created_at desc
    limit 1
    """
    |> Db.query([query], to_json: true)
    |> IO.inspect
    |> get_text
    |> (&Plug.Conn.send_resp(conn, 200, &1)).()
  end

  defp get_text({:ok, [%{"text" => text}]}), do: text
end
