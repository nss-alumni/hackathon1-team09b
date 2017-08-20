defmodule NssTilWeb.SearchController do
  use NssTilWeb, :controller

  alias NssTil.Db
  alias NssTilWeb.Response

  def search(conn, params) do
    query = params["q"]

    """
    with search as (
      select
        id,
        text,
        ts_rank(to_tsvector(t.text), plainto_tsquery('english', $1))
          + similarity(t.text, $1) rank
      from til.til t
    )
    select *
    from search
    order by rank desc
    """
    |> Db.query([query], to_json: true)
    |> Response.send_response(conn)
  end
end
