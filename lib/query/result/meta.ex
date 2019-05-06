defmodule Query.Result.Meta do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Query.Result.Data

  @type t :: %{
          total: non_neg_integer() | nil,
          total_pages: non_neg_integer() | nil,
          page: non_neg_integer(),
          page_total: non_neg_integer()
        }

  @spec new(Query.t(), list) :: Query.Result.Meta.t()
  def new(query, data \\ []) do
    %{}
    |> put_total(query)
    |> put_total_pages(query)
    |> put_page(query)
    |> put_page_total(data)
  end

  defp put_total(meta, %Query{count: true, count_column: column} = query) do
    total =
      query
      |> Data.with_scopes()
      |> maybe_limit(query)
      |> query.repo.aggregate(:count, column)

    Map.put(meta, :total, total)
  end

  defp put_total(meta, _query) do
    Map.put(meta, :total, nil)
  end

  defp maybe_limit(query, %Query{count_limit: :infinite}) do
    query
  end

  defp maybe_limit(query, %Query{count_limit: limit}) do
    limit(query, ^limit)
  end

  defp put_total_pages(%{total: total} = meta, %Query{limit: limit})
       when is_integer(total) and limit > 0 do
    Map.put(meta, :total_pages, round(Float.ceil(total / limit)))
  end

  defp put_total_pages(%{total: total} = meta, _query) when is_integer(total) do
    Map.put(meta, :total_pages, 0)
  end

  defp put_total_pages(meta, _) do
    Map.put(meta, :total_pages, nil)
  end

  defp put_page(meta, %Query{page: page}) do
    Map.put(meta, :page, page)
  end

  defp put_page_total(meta, data) do
    Map.put(meta, :page_total, Enum.count(data))
  end
end
