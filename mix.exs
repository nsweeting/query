defmodule Query.Mixfile do
  use Mix.Project

  def project do
    [
      app: :query,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      aliases: aliases(),
      description: description(),
      package: package(),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: applications(Mix.env)
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
      links:  %{"GitHub" => "https://github.com/nsweeting/query"}
    ]
  end

  defp aliases do
    [
      "db.reset": [
        "ecto.drop",
        "ecto.create",
        "ecto.migrate"
      ]
    ]
  end

  defp applications(:test), do: [:postgrex, :ecto, :logger]
  defp applications(_), do: [:logger]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.1"},
      {:postgrex, "~> 0.13.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
