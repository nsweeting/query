use Mix.Config

config :query, [
  ecto_repos: [Query.Ecto.Repo]
]

config :query, Query.Ecto.Repo, [
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "query_test",
  username: "nick",
  password: "nick"
]

config :logger, :console, [
  level: :error
]

config :query, [
  repo: Query.Ecto.Repo,
]
