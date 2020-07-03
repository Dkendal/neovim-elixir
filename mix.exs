defmodule NVim.Mixfile do
  use Mix.Project

  def project do
    [
      app: :neovim,
      version: "0.2.0",
      consolidate_protocols: false,
      elixir: "~> 1.0",
      escript: escript(),
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:logger, :mix, :eex, :ex_unit, :iex, :procket, :message_pack],
      mod: {NVim.App, []},
      env: [update_api_on_startup: true]
    ]
  end

  defp deps do
    [
      # TODO bump
      {:message_pack, github: "awetzel/msgpack-elixir", branch: "unpack_map_as_map"},
      # TODO remove or lock to ref
      {:procket, github: "msantos/procket", branch: "master"},
      {:logger_file_backend, "~> 0.0.11"},
      {:dialyxir, "~> 1.0.0", only: [:dev, :test]}
    ]
  end

  defp escript,
    do: [
      emu_args: "-noinput",
      path: "./bin/nvim_elixir_host",
      strip_beam: false,
      main_module: Sleeper
    ]
end
