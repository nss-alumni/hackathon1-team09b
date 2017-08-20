defmodule NssTil.Db do
  @moduledoc """
  Operations to work with raw database queries.
  """

  def query(query, params \\ []) do
    Ecto.Adapters.SQL.query(NssTil.Repo, query, params)
    |> format
  end

  defp format({:error, message}), do: {:error, message.postgres.message}
  defp format({:ok, %Postgrex.Result{columns: nil}}), do: {:ok, []}
  defp format({:ok, %Postgrex.Result{columns: columns, rows: rows}}) do
    {:ok, Enum.map(rows, &rows_to_maps(columns, &1))}
  end

  defp rows_to_maps(columns, row) do
    columns
    |> Enum.zip(row)
    |> Enum.into(%{})
  end
end
