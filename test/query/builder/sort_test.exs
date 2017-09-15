defmodule Query.Builder.SortTest do
  use ExUnit.Case

  alias Query.Builder.Sort

  test "creating a sort with no sorting options will assign the default" do
    sorting = Sort.new()
    assert [asc: :id] == sorting
  end

  test "creating a sort with sorting options will use the options" do
    sorting = Sort.new(%{}, [default_dir: "desc"])
    assert [desc: :id] == sorting
    sorting = Sort.new(%{}, [default_sort: "address"])
    assert [asc: :address] == sorting
  end

  test "creating a sort with valid sorting params will use the params" do
    sorting = Sort.new(%{"sort_by" => "address"}, [permitted: ["address"]])
    assert [asc: :address] == sorting
  end

  test "creating a sort with invalid sorting params will use the defaults" do
    sorting = Sort.new(%{"sort_by" => "address"}, [permitted: []])
    assert [asc: :id] == sorting
  end

  test "creating a sort with new sort keys will use the params" do
    sorting = Sort.new(%{"sort1" => "address"}, [sort_param: "sort1", permitted: ["address"]])
    assert [asc: :address] == sorting
  end

  test "creating a sort with new dir keys will use the params" do
    sorting = Sort.new(%{"dir1" => "desc"}, [dir_param: "dir1"])
    assert [desc: :id] == sorting
  end

  test "creating a sort with invalid dir will use the default" do
    sorting = Sort.new(%{"direction" => "bad"}, [])
    assert [asc: :id] == sorting
  end

  test "creating a sort with valid dir will use the param" do
    sorting = Sort.new(%{"direction" => "desc"}, [])
    assert [desc: :id] == sorting
  end
end
