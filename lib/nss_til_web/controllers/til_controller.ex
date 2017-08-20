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

  defp send_response({:error, message}, conn) do
    conn
    |> Plug.Conn.put_status(:internal_server_error)
    |> json(error(message))
  end

  defp send_response({:ok, data}, conn) do
    json(conn, success(data))
  end

  defp success(data), do: %{status: "success", data: data}
  defp error(message), do: %{status: "error", errors: [%{message: message}]}
end
