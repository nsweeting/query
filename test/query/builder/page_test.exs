defmodule Query.Builder.PageTest do
  use ExUnit.Case

  alias Query.Builder.Page

  test "creating a page with no paging options will assign the default" do
    paging = Page.new()
    assert {20, 0, 1} == paging
  end

  test "creating a page with paging options will use the options" do
    paging = Page.new(%{}, [default_page: 2])
    assert {20, 20, 2} == paging
    paging = Page.new(%{}, [default_limit: 50])
    assert {50, 0, 1} == paging
  end

  test "creating a page with valid paging params will use the params" do
    paging = Page.new(%{"limit" => 10, "page" => 2}, [])
    assert {10, 10, 2} == paging
  end

  test "creating a page with invalid paging params will use the defaults" do
    paging = Page.new(%{"limit" => 50, "page" => 2}, [])
    assert {20, 20, 2} == paging
  end

  test "creating a page with new limit keys will use the params" do
    paging = Page.new(%{"limit1" => 10}, [limit_param: "limit1"])
    assert {10, 0, 1} == paging
  end

  test "creating a page with new page keys will use the params" do
    paging = Page.new(%{"page1" => 2}, [page_param: "page1"])
    assert {20, 20, 2} == paging
  end
end
