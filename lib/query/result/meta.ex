defmodule Query.Result.Meta do
  @moduledoc """
  Provides paging meta for our Query.Result.
  """

  @type t :: %{
    total:       integer,
    total_pages: integer,
    page:        integer,
    page_total:  integer
  }

  import Ecto.Query, warn: false

  alias Query.Builder

  @doc """
  Creates a new meta map from a Query.Builder and data list.

  ## Parameters

    - builder: A Query.Builder struct.
    - data: Our data list.

  ## Examples

      iex> Query.Result.Meta.new(builder, data)
      %{page: 1, page_total: 2, total: 2, total_pages: 1}
  """
  @spec new(Query.Builder.t, list) :: Query.Result.Meta.t
  def new(%Builder{} = builder, data \\ []) do
    %{}
    |> put_total(builder)
    |> put_total_pages(builder)
    |> put_page(builder)
    |> put_page_total(data)
  end

  defp put_total(meta, %Builder{queryable: queryable, repo: repo}) do
    total = queryable
    |> select(count("*"))
    |> repo.one()

    Map.put(meta, :total, total)
  end

  defp put_total_pages(%{total: total} = meta, %Builder{limit: limit})
  when limit > 0 do
    Map.put(meta, :total_pages, round(Float.ceil(total / limit)))
  end
  defp put_total_pages(meta, _) do
    Map.put(meta, :total_pages, 0)
  end

  defp put_page(meta, %Builder{page: page}) do
    Map.put(meta, :page, page)
  end

  defp put_page_total(meta, data) do
    Map.put(meta, :page_total, Enum.count(data))
  end
end
