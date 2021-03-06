defmodule PruBlink.Mixfile do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"

  Mix.shell.info([:green, """
  Mix environment
    MIX_TARGET:   #{@target}
    MIX_ENV:      #{Mix.env}
  """, :reset])

  def project do
    [app: :pru_example,
     version: "0.1.0",
     elixir: "~> 1.4",
     compilers: [:elixir_make | Mix.compilers],
     make_clean: ["clean"],
     # make_env: %{ "PRU_CGT" => System.user_home() <> "/.nerves/artifacts/extras_toolchain_pru_cgt-portable-0.1.0/ti-cgt-pru/"},
     target: @target,
     archives: [nerves_bootstrap: "~> 0.6"],
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
  # invoke PruBlink.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end
  def application(_target) do
    [mod: {PruBlink, []},
     extra_applications: [:logger]]
  end

  def deps do
    [
     {:toolchain_extras_pru_cgt, "~> 0.2", git: "https://github.com/elcritch/extras_toolchain_pru_cgt.git", branch: "v0.2.x-host_tools_fork"},
     # {:nerves, git: "https://github.com/nerves-project/nerves.git", branch: "host_tools", override: true },
     {:nerves, git: "https://github.com/elcritch/nerves.git", branch: "host_tools_fork", override: true },
     {:elixir_make, "~> 0.3"},
     {:msgpax, "~> 2.1"},
     {:elixir_ale, "~> 1.0"},

     # {:pru, "~> 0.1.0"},
     # {:pru, "~> 0.2.0", path: "../pru/"},

     # {:nerves_pru_support, git: "https://github.com/elcritch/nerves_pru_support.git", branch: "master"},
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  def deps("host"), do: []
  def deps(target) do
    [
      # {:bootloader, "~> 0.1"},
      {:nerves_runtime, "~> 0.5"},
      {:nerves_network, "~> 0.3"},
      # {:nerves_init_gadget, "~> 0.2"},
      {:nerves_network_interface, "~> 0.4"},
      {:nerves_firmware_ssh, "~> 0.2"},
    ] ++ system(target)
  end

  def system("rpi"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system("rpi0"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system("rpi2"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system("rpi3"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system("bbb"), do: [{:nerves_system_bbb, "~> 0.20.0", runtime: false}]
  def system("bbb_pru"), do: [{:nerves_system_bbb, "~> 0.20.0", github: "elcritch/nerves_system_bbb", branch: "manual-add-ti-cgt-pru",  runtime: false}]
  def system("bbb_custom") do
    [{:nerves_system_bbb,
     path: "../nerves_system_bbb",
     runtime: false}]
    # {:nerves_system_bbb_pru,
    # branch: "master", git: "https://github.com/elcritch/nerves_system_bbb.git", runtime: false}

  end

  def system("linkit"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system("ev3"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system("qemu_arm"), do: Mix.raise "Sorry, this example only works on BeagleBone Black/Green"
  def system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  # We do not invoke the Nerves Env when running on the Host
  def aliases("host"), do: []
  def aliases(_target) do
    # ["deps.precompile": ["nerves.precompile", "deps.precompile"],
    #  "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
    []
    |> Nerves.Bootstrap.add_aliases()
  end
end
