defmodule ICAN.MixProject do
  use Mix.Project

  def project do
    [
      app: :ican,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "ICAN (International Crypto Account Number). An encoding for asset/crypto addresses",
      package: [
        maintainers: ["Airat Badykov"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/ayrat555/ican"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4", only: :test},
      {:styler, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
