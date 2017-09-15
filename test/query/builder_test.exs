defmodule Query.BuilderTest do
  use ExUnit.Case

  test "can create a Builder from an atom queryable" do
    queryable = Ecto.Queryable.to_query(Query.Ecto.Post)
    builder = Query.Builder.new(Query.Ecto.Post)
    assert queryable == builder.queryable
  end

  test "creating a Builder with no paging options will assign defaults" do
    builder = Query.Builder.new(Query.Ecto.Post)
    assert 20 == builder.limit
    assert 0 == builder.offset
    assert 1 == builder.page
  end

  test "creating a Builder with paging options will use the options" do
    builder = Query.Builder.new(Query.Ecto.Post, %{}, paging: [default_limit: 50])
    assert 50 == builder.limit
    assert 0 == builder.offset
    assert 1 == builder.page
  end

  test "creating a Builder with no sorting options will assign the default" do
    builder = Query.Builder.new(Query.Ecto.Post)
    assert [asc: :id] == builder.sorting
  end

  test "creating a Builder with sorting options will use the options" do
    builder = Query.Builder.new(Query.Ecto.Post, %{}, sorting: [default_dir: "desc"])
    assert [desc: :id] == builder.sorting
  end

  test "creating a Builder with no scope options will assign an empty list" do
    builder = Query.Builder.new(Query.Ecto.Post)
    assert [] == builder.scopes
  end

  test "creating a Builder with no repo options will assign the default" do
    builder = Query.Builder.new(Query.Ecto.Post)
    assert Query.Ecto.Repo == builder.repo
  end

  test "creating a Builder with repo options will use the options" do
    builder = Query.Builder.new(Query.Ecto.Post, %{}, repo: Query)
    assert Query == builder.repo
  end
end
