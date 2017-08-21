defmodule NssTilWeb.Plugs.Auth do
  import Plug.Conn

  alias NssTil.Db

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    access_token = conn |> Plug.Conn.get_req_header("x-access-token") |> List.first
    slack_id = conn |> Plug.Conn.get_req_header("x-slack-user-id") |> List.first
    user_id = get_user_id(slack_id)

    conn = if user_id == nil do
      access_token
      |> fetch_slack_user
      |> save_user_info
      |> assign_user_id(conn)
    else
      user_id
      |> assign_user_id(conn)
    end

    if conn.assigns[:user_id] do
      conn
    else
      conn
      |> Plug.Conn.send_resp(401, "")
      |> halt()
    end
  end

  defp get_user_id(nil), do: nil
  defp get_user_id(slack_id) do
    """
    select id from til.user where slack_id = $1
    """
    |> Db.query([slack_id], to_json: false)
    |> first_result
    |> get_id
  end

  defp assign_user_id(user_id, conn) do
    conn
    |> Plug.Conn.assign(:user_id, user_id)
  end

  def fetch_slack_user(access_token) do
    "https://slack.com/api/users.identity?token=#{access_token}"
    |> HTTPoison.get
  end

  defp save_user_info({:error, %HTTPoison.Error{reason: reason}}), do: log_error(reason)
  defp save_user_info({:error, _} = error), do: log_error(error)
  defp save_user_info({:ok, %HTTPoison.Response{body: body}}) do
    parsed = body |> Poison.decode! |> Map.get("user")

    slack_id = parsed["id"]
    name = parsed["name"]
    email = parsed["email"]
    image_url = parsed["image_192"]

    """
    insert into til.user
      (slack_id, name, email, image_url) values
      ($1, $2, $3, $4)
    returning
      id
    """
    |> Db.query([slack_id, name, email, image_url], to_json: false)
    |> first_result
    |> get_id
  end

  defp first_result({:error, _} = error), do: log_error(error)
  defp first_result({:ok, []}), do: nil
  defp first_result({:ok, [_ | _] = list}), do: list |> List.first

  defp get_id(%{"id" => id}), do: id
  defp get_id(_), do: nil

  defp log_error({:error, message}) do
    Logger.error(message)
    nil
  end
end
