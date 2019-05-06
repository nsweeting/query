defmodule QueryTest do
  use Query.Ecto.TestCase

  alias Query.Context
  alias Query.Ecto.{Comment, Post, Repo}

  describe "run/4" do
    test "will query with default paging, sorting and scoping" do
      create_posts()

      result = Query.run(Post, Repo)

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with custom page_default" do
      create_posts()

      result = Query.run(Post, Repo, %{}, page_default: 2)

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 2 == result.meta.page
    end

    test "will query with custom page_param" do
      create_posts()

      result = Query.run(Post, Repo, %{"foo" => 2}, page_param: "foo")

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 2 == result.meta.page
    end

    test "will query with custom limit_param" do
      create_posts()

      result = Query.run(Post, Repo, %{"foo" => 1}, limit_param: "foo")

      assert 1 == Enum.count(result.data)
      assert 1 == result.meta.page_total
      assert 56 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with custom limit_default" do
      create_posts()

      result = Query.run(Post, Repo, %{}, limit_default: 10)

      assert 10 == Enum.count(result.data)
      assert 10 == result.meta.page_total
      assert 6 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with custom limit_max" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => 20}, limit_max: 10)

      assert 10 == Enum.count(result.data)
      assert 10 == result.meta.page_total
      assert 6 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with custom sort_default" do
      create_posts()

      result = Query.run(Comment, Repo, %{}, sort_default: "post_id")
      [one, two, three, four, five | _] = result.data

      assert one.post_id <= two.post_id
      assert two.post_id <= three.post_id
      assert three.post_id <= four.post_id
      assert four.post_id <= five.post_id
    end

    test "will query with custom sort_param and sort_permitted" do
      create_posts()

      result =
        Query.run(Comment, Repo, %{"foo" => "post_id"},
          sort_param: "foo",
          sort_permitted: ["post_id"]
        )

      [one, two, three, four, five | _] = result.data

      assert one.post_id <= two.post_id
      assert two.post_id <= three.post_id
      assert three.post_id <= four.post_id
      assert four.post_id <= five.post_id
    end

    test "will query with bad sort_by" do
      create_posts()

      result = Query.run(Comment, Repo, %{"sort_by" => "foo"})

      [one, two, three, four, five | _] = result.data

      assert one.id <= two.id
      assert two.id <= three.id
      assert three.id <= four.id
      assert four.id <= five.id
    end

    test "will query with custom dir_default" do
      create_posts()

      result = Query.run(Post, Repo, %{}, dir_default: "desc")

      [one, two, three, four, five | _] = result.data

      assert one.id >= two.id
      assert two.id >= three.id
      assert three.id >= four.id
      assert four.id >= five.id
    end

    test "will query with custom dir_param" do
      create_posts()

      result = Query.run(Post, Repo, %{"foo" => "desc"}, dir_param: "foo")

      [one, two, three, four, five | _] = result.data

      assert one.id >= two.id
      assert two.id >= three.id
      assert three.id >= four.id
      assert four.id >= five.id
    end

    test "will query with bad dir" do
      create_posts()

      result = Query.run(Post, Repo, %{"dir" => "foo"})

      [one, two, three, four, five | _] = result.data

      assert one.id <= two.id
      assert two.id <= three.id
      assert three.id <= four.id
      assert four.id <= five.id
    end

    test "will query with custom scope of published: false" do
      create_posts()

      params = %{"published" => false, "page" => 2}
      options = [scope_permitted: ["published"], scope: {Context, :with_scope}]
      result = Query.run(Post, Repo, params, options)

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 50 == result.meta.total
      assert 2 == result.meta.page

      Enum.each(result.data, fn post ->
        assert post.published == false
      end)
    end

    test "will query with custom scope of published: true" do
      create_posts()

      params = %{"published" => true}
      options = [scope_permitted: ["published"], scope: {Context, :with_scope}]
      result = Query.run(Post, Repo, params, options)

      assert 6 == Enum.count(result.data)
      assert 6 == result.meta.page_total
      assert 1 == result.meta.total_pages
      assert 6 == result.meta.total
      assert 1 == result.meta.page

      Enum.each(result.data, fn post ->
        assert post.published == true
      end)
    end

    test "will query with limit" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => 2})

      assert 2 == Enum.count(result.data)
      assert 2 == result.meta.page_total
      assert 28 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with negative limit" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => -10})

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with string limit" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => "2"})

      assert 2 == Enum.count(result.data)
      assert 2 == result.meta.page_total
      assert 28 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with bad limit" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => "bad"})

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with limit 0" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => 0})

      assert 0 == Enum.count(result.data)
      assert 0 == result.meta.page_total
      assert 0 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with limit and page" do
      create_posts()

      result = Query.run(Post, Repo, %{"limit" => 2, "page" => 2})

      assert 2 == Enum.count(result.data)
      assert 2 == result.meta.page_total
      assert 28 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 2 == result.meta.page
    end

    test "will query with negative page" do
      create_posts()

      result = Query.run(Post, Repo, %{"page" => -2})

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query with string page" do
      create_posts()

      result = Query.run(Post, Repo, %{"page" => "2"})

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 2 == result.meta.page
    end

    test "will query with bad page" do
      create_posts()

      result = Query.run(Post, Repo, %{"page" => "bad"})

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 3 == result.meta.total_pages
      assert 56 == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query without returning a total" do
      create_posts()

      result = Query.run(Post, Repo, %{}, count: false)

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert nil == result.meta.total_pages
      assert nil == result.meta.total
      assert 1 == result.meta.page
    end

    test "will query and return a total with limit" do
      create_posts()

      result = Query.run(Post, Repo, %{}, count_limit: 5)

      assert 20 == Enum.count(result.data)
      assert 20 == result.meta.page_total
      assert 1 == result.meta.total_pages
      assert 5 == result.meta.total
      assert 1 == result.meta.page
    end
  end

  defp create_posts do
    Enum.map(1..50, fn i ->
      post =
        %Post{
          title: "Title #{i}",
          body: "Body #{i}",
          published: false
        }
        |> Query.Ecto.Repo.insert!()

      Enum.map(1..2, fn i ->
        %Comment{
          body: "Body #{i}",
          post_id: post.id
        }
        |> Query.Ecto.Repo.insert!()
      end)
    end)

    Enum.map(1..6, fn i ->
      %Post{
        title: "Title #{i}",
        body: "Body #{i}",
        published: true
      }
      |> Query.Ecto.Repo.insert!()
    end)
  end
end
