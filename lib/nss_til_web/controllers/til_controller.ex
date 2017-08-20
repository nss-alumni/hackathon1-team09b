defmodule NssTilWeb.TilController do
  use NssTilWeb, :controller

  alias NssTil.Db

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
    |> Db.query
    |> send_response(conn)
  end

  defp send_response({:ok, data}, conn), do: json(conn, success(data))

  defp success(data), do: %{status: "success", data: data}
end
