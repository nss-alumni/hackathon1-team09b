defmodule NssTilWeb.Response do
  @moduledoc """
  Manipulate responses to align with the JSON API standard.
  """

  import Phoenix.Controller, only: [json: 2]

  def send_response({:error, message}, conn) do
    conn
    |> Plug.Conn.put_status(:internal_server_error)
    |> json(error(message))
  end

  def send_response({:ok, data}, conn) do
    json(conn, success(data))
  end

  defp success(data), do: %{status: "success", data: data}
  defp error(message), do: %{status: "error", errors: [%{message: message}]}
end
