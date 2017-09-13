defmodule Query do

  @spec builder(atom | Ecto.Queryable.t, map, list) :: Query.Builder.t
  def builder(queryable, params \\ %{}, options \\ []) do
    Query.Builder.new(queryable, params, options)
  end

  def result(builder) do
    Query.Result.new(builder)
  end
end
