defmodule Query.Config do
  @moduledoc false

  def options(:builder, opts \\ []) do
    [
      paging: get(:paging, []),
      sorting: get(:sorting, []),
      repo: get(:repo),
      scopes: []
    ]
    |> Keyword.merge(opts)
  end

  def get(key, default \\ nil) do
    Application.get_env(:query, key, default)
  end

  def get_sub(key, subkey, default \\ nil) do
    config = Application.get_env(:query, key, [])
    Keyword.get(config, subkey, default)
  end
end
