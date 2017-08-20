defmodule NssTil.Db do
  @moduledoc """
  Operations to work with raw database queries.
  """

  def query(query, params \\ [], to_json: to_json) do
    json_fun = if to_json, do: &rows_to_json/1, else: &(&1)

    Ecto.Adapters.SQL.query(NssTil.Repo, query, params)
    |> format
    |> (json_fun).()
  end

  defp format({:error, message}), do: {:error, message.postgres.message}
  defp format({:ok, %Postgrex.Result{rows: nil}}), do: {:ok, []}
  defp format({:ok, %Postgrex.Result{columns: columns, rows: rows}}) do
    {:ok, Enum.map(rows, &rows_to_maps(columns, &1))}
  end

  defp rows_to_maps(columns, row) do
    columns
    |> Enum.zip(row)
    |> Enum.into(%{})
  end

  defp rows_to_json({:error, _} = error), do: error
  defp rows_to_json({:ok, []} = empty), do: empty
  defp rows_to_json({:ok, [%{} | _] = rows}) do
    json_rows = rows
    |> Enum.map(&Atomizer.to_json/1)

    {:ok, json_rows}
  end
end
