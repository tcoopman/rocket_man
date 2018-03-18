defmodule Fw.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: :fw,
      version: "0.1.0",
      elixir: "~> 1.4",
      target: @target,
      archives: [nerves_bootstrap: "~> 0.8"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "mix.lock.#{@target}",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: [loadconfig: [&bootstrap/1], test: "test --no-start"],
      deps: deps()
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: application(@target)

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke Fw.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end

  def application(_target) do
    [mod: {Fw.Application, []}, extra_applications: [:logger]]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 0.9", runtime: false},
      {:elixir_ale, "~> 1.0"},
      {:ui, path: "../ui"},
      {:mox, "~> 0.3", only: :test}
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  defp deps("host"), do: []

  defp deps(target) do
    [
      {:shoehorn, "~> 0.2"},
      {:nerves_runtime, "~> 0.4"},
      {:nerves_init_gadget, "~> 0.2"}
    ] ++ system(target)
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["hardware", "lib"]

  defp system("rpi"), do: [{:nerves_system_rpi, ">= 0.0.0", runtime: false}]
  defp system("rpi0"), do: [{:nerves_system_rpi0, ">= 0.0.0", runtime: false}]
  defp system("rpi2"), do: [{:nerves_system_rpi2, ">= 0.0.0", runtime: false}]
  defp system("rpi3"), do: [{:nerves_system_rpi3, ">= 0.0.0", runtime: false}]
  defp system("bbb"), do: [{:nerves_system_bbb, ">= 0.0.0", runtime: false}]
  defp system("ev3"), do: [{:nerves_system_ev3, ">= 0.0.0", runtime: false}]
  defp system("qemu_arm"), do: [{:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}]
  defp system("x86_64"), do: [{:nerves_system_x86_64, ">= 0.0.0", runtime: false}]
  defp system(target), do: Mix.raise("Unknown MIX_TARGET: #{target}")
end
