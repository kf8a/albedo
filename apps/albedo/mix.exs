defmodule Albedo.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell.info([:green, """
  Mix environment
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])

  def project do
    [app: :albedo,
     version: "0.1.0",
     elixir: "~> 1.4.0",
     description: description(),
     package: package(),
     target: @target,
     archives: [nerves_bootstrap: "~> 0.4.0"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     lockfile: "mix.lock.#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(@target),
     deps: deps()]
  end



  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application, do: application(@target)

  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke Albedo.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end
  def application(_target) do
    [mod: {Albedo.Application, [:xgps, :nerves_leds]},
     extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  def deps do
    [
      {:ui, in_umbrella: true},
      {:nerves, "~> 0.6.0", runtime: false},
      {:nerves_uart, "~> 0.1"},
      {:xgps, "~> 0.4.0"},
      {:bootloader, "~> 0.1"},
      {:nerves_init_gadget, github: "fhunleth/nerves_init_gadget", branch: "master"}
    ] ++
    deps(@target)
  end

  # Specify target specific dependencies
  def deps("host"), do: [
    {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
  ]
  def deps(target) do
    [ system(target),
      {:nerves_runtime, "~> 0.4.0"},
      {:nerves_leds, "~> 0.7.0"},
      {:elixir_ale, "~> 1.0"}
    ]
  end


  def system("rpi"), do: {:nerves_system_rpi, ">= 0.0.0", runtime: false}
  def system("rpi0"), do: {:nerves_system_rpi0, ">= 0.0.0", runtime: false}
  def system("rpi2"), do: {:nerves_system_rpi2, ">= 0.0.0", runtime: false}
  def system("rpi3"), do: {:nerves_system_rpi3, ">= 0.0.0", runtime: false}
  def system("bbb"), do: {:nerves_system_bbb, ">= 0.0.0", runtime: false}
  def system("linkit"), do: {:nerves_system_linkit, ">= 0.0.0", runtime: false}
  def system("ev3"), do: {:nerves_system_ev3, ">= 0.0.0", runtime: false}
  def system("qemu_arm"), do: {:nerves_system_qemu_arm, ">= 0.0.0", runtime: false}
  def system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  # We do not invoke the Nerves Env when running on the Host
  def aliases("host"), do: []
  def aliases(_target) do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

  defp description do
    """
    A project to measure albedo with an upward and downward facing thermopile sensor from apogee https://www.apogeeinstruments.com/content/SP-510-610-manual.pdf
    """
  end

  defp package do
    [
      maintainers: ["Sven Bohm"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kf8a/albedo"}
    ]
  end
end
