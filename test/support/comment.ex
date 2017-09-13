defmodule Query.Ecto.Comment do
  use Ecto.Schema

  schema "comments" do
    field :body, :string

    belongs_to :post, Query.Ecto.Post

    timestamps()
  end
end