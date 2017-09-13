defmodule Query.Result.Meta do
  @moduledoc false

  import Ecto.Query, warn: false

  alias Query.Builder

  def new(%Builder{} = builder, data \\ []) do
    %{
      total: get_total(builder),
      page: get_page(builder),
      page_total: get_page_total(data)
    }
  end

  defp get_total(%Builder{} = builder) do
    builder.queryable
    |> select(count("*"))
    |> builder.repo.one()
  end

  defp get_page(%Builder{page: page}) do
    page
  end

  defp get_page_total(data) do
    Enum.count(data)
  end
end
