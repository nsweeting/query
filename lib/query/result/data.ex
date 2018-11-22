defmodule Query.Result.Data do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Query.Builder

  @spec new(Query.Builder.t()) :: list
  def new(%Builder{} = builder) do
    builder
    |> with_scopes()
    |> order_by(^builder.sorting)
    |> limit(^builder.limit)
    |> offset(^builder.offset)
    |> builder.repo.all()
  end

  @spec with_scopes(Query.Builder.t()) :: Ecto.Query.t()
  def with_scopes(%Builder{} = builder) do
    Enum.reduce(builder.scopes, builder.queryable, fn {context, scope, [value]}, queryable ->
      funcs = context.module_info(:exports)

      case Keyword.get(funcs, scope) do
        2 -> apply(context, scope, [queryable, value])
        _ -> queryable
      end
    end)
  end
end
