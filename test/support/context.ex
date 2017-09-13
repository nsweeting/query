defmodule Query.Context do
  import Ecto.Query

  def published(query, boolean) do
    query |> where([p], p.published == ^boolean)
  end
end
