defmodule NssTilWeb.Response do
  @moduledoc """
  Manipulate responses to align with the JSON API standard.
  """

  import Phoenix.Controller, only: [json: 2]

  alias Plug.Conn

  def send_response({:error, message}, conn) do
    conn
    |> Conn.put_status(:internal_server_error)
    |> Conn.put_resp_content_type("application/json")
    |> json(error(message))
  end

  def send_response({:ok, data}, conn) do
    conn
    |> Conn.put_resp_content_type("application/json")
    |> json(success(data))
  end

  defp success(data), do: %{status: "success", data: data}
  defp error(message), do: %{status: "error", errors: [%{message: message}]}
end
