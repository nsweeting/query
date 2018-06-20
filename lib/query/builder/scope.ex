defmodule Query.Builder.Scope do
  @moduledoc """
  Provides scoping details for our Query.Builder.
  """

  @doc """
  Provides scoping details based on the provided params and possible scopes.

  ## Parameters

    - params: A param map - most likely from a controller.
    - scopes: A list of possible scopes, formatted as two item tuples.

  ## Examples

      iex> Query.Builder.Scope.new(%{"by_title" => "title"}, [{App.Context, "by_title"}, {App.Context, "by_name"}])
      [{App.Context, :by_title, ["title"]}]
  """
  def new(params \\ %{}, scopes \\ [])

  def new(params, scopes)
      when is_map(params) and is_list(scopes) do
    scopes
    |> Enum.flat_map(&new(params, &1))
    |> Enum.reject(&is_nil/1)
  end

  def new(params, scope)
      when is_map(params) and is_tuple(scope) do
    Enum.map(params, &new(&1, scope))
  end

  def new({query, value}, {context, scope}) do
    if query == scope, do: {context, String.to_atom(scope), [value]}, else: nil
  end
end
