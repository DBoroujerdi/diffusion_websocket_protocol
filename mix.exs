defmodule Diffusion.Websocket.Protocol.Mixfile do
  use Mix.Project

  def project do
    [app: :diffusion_websocket_protocol,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    []
  end

  defp deps do
    [{:dialyxir, "~> 0.4", only: [:dev], runtime: false}]
  end
end
