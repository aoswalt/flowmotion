defmodule Flowmotion.MixProject do
  use Mix.Project

  def project do
    [
      app: :flowmotion,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Flowmotion.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:typed_struct, "~> 0.1.4"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end
end
