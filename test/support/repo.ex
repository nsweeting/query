defmodule Query.Ecto.Repo do
  use Ecto.Repo, otp_app: :query_test, adapter: Ecto.Adapters.Postgres

  def init(_arg, config) do
    config =
      Keyword.merge(config,
        adapter: Ecto.Adapters.Postgres,
        pool: Ecto.Adapters.SQL.Sandbox,
        database: "query_test",
        hostname: "localhost",
        port: 5434,
        username: "postgres"
      )

    {:ok, config}
  end
end
