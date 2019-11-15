defmodule Query.Context do
  import Ecto.Query

  def with_scope(query, params) do
    Enum.reduce(params, query, fn
      {"published", val}, query when is_boolean(val) ->
        query |> where([p], p.published == ^val)
    end)
  end
end
