defmodule NssTilWeb.TilController do
  use NssTilWeb, :controller

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
    |> query
    |> format
    |> send_response(conn)
  end

  defp query(query, params \\ []), do: Ecto.Adapters.SQL.query(NssTil.Repo, query, params)

  defp send_response({:ok, data}, conn), do: json(conn, success(data))

  defp success(data), do: %{status: "success", data: data}

  defp format({:ok, %Postgrex.Result{columns: columns, rows: rows}}) do
    {:ok, Enum.map(rows, &rows_to_maps(columns, &1))}
  end

  defp rows_to_maps(columns, row) do
    columns
    |> Enum.zip(row)
    |> Enum.into(%{})
  end
end
