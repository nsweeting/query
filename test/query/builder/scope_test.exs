defmodule Query.Builder.ScopeTest do
  use ExUnit.Case

  alias Query.Builder.Scope

  test "creating a scope with no scoping options will assign the default" do
    scoping = Scope.new()
    assert [] == scoping
  end

  test "creating a scope with scoping options will use the options" do
    scoping = Scope.new(%{"search" => "test"}, [{Query, "search"}])
    assert [{Query, :search, ["test"]}] == scoping
  end

  test "creating a scope with invalid scoping options will use the defaults" do
    scoping = Scope.new(%{"search" => "test"}, [{Query, "another"}])
    assert [] == scoping
  end
end
