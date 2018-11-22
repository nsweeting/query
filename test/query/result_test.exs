defmodule Query.ResultTest do
  use Query.Ecto.TestCase
  use ExUnit.Case

  alias Query.Ecto.{Comment, Post}

  test "can create a valid Result from a Builder with published false scope" do
    create_posts()

    params = %{"published" => false, "page" => 2}
    options = [scopes: [{Query.Context, "published"}]]

    result =
      Query.Ecto.Post
      |> Query.builder(params, options)
      |> Query.result()

    assert 20 == Enum.count(result.data)
    assert 20 == result.meta.page_total
    assert 3 == result.meta.total_pages
    assert 50 == result.meta.total
    assert 2 == result.meta.page

    Enum.each(result.data, fn post ->
      assert post.published == false
    end)
  end

  test "can create a valid Result from a Builder with published true scope" do
    create_posts()

    params = %{"published" => true}
    options = [scopes: [{Query.Context, "published"}]]

    result =
      Query.Ecto.Post
      |> Query.builder(params, options)
      |> Query.result()

    assert 6 == Enum.count(result.data)
    assert 6 == result.meta.page_total
    assert 1 == result.meta.total_pages
    assert 6 == result.meta.total
    assert 1 == result.meta.page

    Enum.each(result.data, fn post ->
      assert post.published == true
    end)
  end

  test "can create a valid Result from a Builder with paging" do
    create_posts()

    params = %{"limit" => 2}

    result =
      Query.Ecto.Post
      |> Query.builder(params)
      |> Query.result()

    assert 2 == Enum.count(result.data)
    assert 2 == result.meta.page_total
    assert 28 == result.meta.total_pages
    assert 56 == result.meta.total
    assert 1 == result.meta.page
  end

  test "can create a valid Result from a Builder with a limit of 0" do
    create_posts()

    params = %{"limit" => 0}

    result =
      Query.Ecto.Post
      |> Query.builder(params)
      |> Query.result()

    assert 0 == Enum.count(result.data)
    assert 0 == result.meta.page_total
    assert 0 == result.meta.total_pages
    assert 56 == result.meta.total
    assert 1 == result.meta.page
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
