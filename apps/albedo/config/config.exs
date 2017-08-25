# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

config :logger,
  backends: [{LoggerFileBackend, :error_log}]
  # level: :info

config :logger, :error_log,
  path: "/root/error.log",
  level: :info

# config UI
config :ui, Ui.Web.Endpoint,
  http: [port: 80],
  url: [host: "nerves.local", port: 80],
  secret_key_base: "AXIG9y+R9sLEeQPVRekdYNFOp86cD8IszypDG72fcOpX+JQo75EmqkbyHwfFcMGD",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Nerves.PubSub],
  code_reload: false

# Boot the bootloader first and have it start our app.
config :bootloader,
  init: [:nerves_init_gadget],
  app: :albedo

# configure GPS module
config :xgps, port_to_start: {"ttyAMA0", :init_adafruit_gps}

# configure leds
config :nerves_leds, names: [ green: "led0" ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations
#import_config "#{Mix.Project.config[:target]}.exs"

config :nerves_firmware_ssh,
  authorized_keys: [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8ptTa9kltyDd41Bs1Mm9SiCw9kxlpJxLCdao2rbEuB9gsbkn+1j0Hx4XybmMpG2DPhlmNxU40YbbMrMBukqkR4EOMLs8qvVot/49QgRaFXZ2Z2LSg/4suPJQp+GMDsxUFI4ERI7V9Luc7iH4oi/9TGsM6b5KhM3tg9sLuv/++cpsbQ53bA421FZsFL4+6QTKPHuvVZi8xoLZqgTxxZNIQXA0ppKk2DmJuwWTl/RgVb/vxV75wkaD8/iHoifYLg86uOAECJ1VTE4eLWLo3Q1xmRpcDkztA3QERxQuzaYOBecbmFpCvHn7j6c5Tb5l+WvAJ9d1TW8XCDlx4Q/7VKfpl" ]
#import_config "ssh.exs"
