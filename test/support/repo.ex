defmodule Query.Ecto.Repo do
  use Ecto.Repo, otp_app: :query, adapter: Ecto.Adapters.Postgres
end
