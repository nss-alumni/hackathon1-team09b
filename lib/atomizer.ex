defmodule Atomizer do
  @moduledoc """
  Strings to and from atoms.
  """

  @doc """
  Create a map with atom keys from a map with snake_case keys.
  """
  def from_string_map(%{} = string_map) do
    string_map
    |> format_keys(&String.to_atom/1)
  end

  @doc """
  Create a map with atom keys from a map with camelCase keys.
  """
  def from_json(%{} = json) do
    json
    |> format_keys(&Macro.underscore/1)
    |> from_string_map
  end

  @doc """
  Convert a map with atom keys to a map with snake_case string keys.
  """
  def to_string_map(%{} = atom_map) do
    atom_map
    |> format_keys(&to_string/1)
  end

  @doc """
  Convert a map with atom keys to a map with camelCase keys.
  """
  def to_json(%{} = atom_map) do
    atom_map
    |> format_keys(&to_camel/1)
  end

  @doc """
  Convert an atom to camelCase.
  """
  def to_camel(key) when is_atom(key) do
    key
    |> to_string
    |> to_camel
  end

  @doc """
  Convert snake_case to camelCase.
  """
  def to_camel(key) do
    key
    |> Macro.camelize
    |> (&(Regex.replace(~r/(^\w)/, &1, fn _, x -> String.downcase(x) end, global: false))).()
  end

  @doc """
  Format keys of a map with a function.
  """
  def format_keys(%{} = map, fun) do
    for {key, val} <- map, into: %{}, do: {fun.(key), val}
  end
end
