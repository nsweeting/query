defmodule Query.Result.Data do
  @moduledoc false

  import Ecto.Query, warn: false

  @spec new(Query.t()) :: list()
  def new(query) do
    query
    |> with_scopes()
    |> order_by(^query.sorting)
    |> limit(^query.limit)
    |> offset(^query.offset)
    |> query.repo.all()
    |> with_preloads(query)
  end

  @spec with_scopes(Query.t()) :: Ecto.Queryable.t()
  def with_scopes(%{scoping: {module, fun, [params]}} = query) do
    apply(module, fun, [query.queryable, params])
  end

  def with_scopes(query) do
    query.queryable
  end

  defp with_preloads(result, query) do
    query.repo.preload(result, query.preloads)
  end
end
