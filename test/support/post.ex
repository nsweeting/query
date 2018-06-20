defmodule Query.Ecto.Post do
  use Ecto.Schema

  schema "posts" do
    field(:title, :string)
    field(:body, :string)
    field(:published, :boolean)

    has_many(:comments, Query.Ecto.Comment)

    timestamps()
  end
end
