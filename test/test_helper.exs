defmodule Query.Ecto.TestCase do
  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      import Ecto.Query
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Query.Ecto.Repo)
  end
end

Query.Ecto.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Query.Ecto.Repo, :manual)

ExUnit.start()
