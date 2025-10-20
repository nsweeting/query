defmodule Query.Mixfile do
  use Mix.Project

  @version "0.6.0"

  def project do
    [
      app: :query,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      preferred_cli_env: preferred_cli_env(),
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: applications(Mix.env())
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  defp aliases do
    [
      setup: [
        "local.hex --if-missing --force",
        "local.rebar --if-missing --force",
        "deps.get"
      ],
      ci: [
        "setup",
        "compile --warnings-as-errors",
        "format --check-formatted",
        "ecto.drop -r Query.Ecto.Repo",
        "ecto.create -r Query.Ecto.Repo",
        "ecto.migrate -r Query.Ecto.Repo",
        "test"
      ]
    ]
  end

  # Specifies the preferred env for mix commands.
  defp preferred_cli_env do
    [
      ci: :test
    ]
  end

  defp description do
    """
    Query adds simple tools to aid the use of Ecto in web settings.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/nsweeting/query"}
    ]
  end

  defp applications(:test), do: [:postgrex, :ecto, :logger]
  defp applications(_), do: [:logger]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.13"},
      {:ecto_sql, "~> 3.13", only: :test},
      {:keyword_validator, "~> 2.0"},
      {:postgrex, "~> 0.19", only: :test},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false}
    ]
  end
end
