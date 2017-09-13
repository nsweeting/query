defmodule Query.Result.Data do
  import Ecto.Query, warn: false

  alias Query.Builder

  def new(%Builder{} = builder) do
    builder.queryable
    |> order_by(^builder.sorting)
    |> limit(^builder.limit)
    |> offset(^builder.offset)
    |> with_scopes(builder.scopes)
    |> builder.repo.all()
  end

  defp with_scopes(queryable, scopes) when is_list(scopes) do
    Enum.reduce(scopes, queryable, fn({context, scope, [value]}, queryable) ->
      funcs = context.module_info(:exports)
      case Keyword.get(funcs, scope) do
        2 -> apply(context, scope, [queryable, value])
        _ -> queryable
      end
    end)
  end
end
