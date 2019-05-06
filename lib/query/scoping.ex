defmodule Query.Scoping do
  @moduledoc false

  @doc false
  def new(params, %{scope: {module, fun}, scope_permitted: scopes}) do
    scopes =
      params
      |> Enum.filter(fn {key, _value} -> Enum.member?(scopes, key) end)
      |> Enum.into(%{})

    {module, fun, [scopes]}
  end

  def new(_params, _config) do
    nil
  end
end
