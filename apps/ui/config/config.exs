# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ui,
  namespace: Ui

# Configures the endpoint
config :ui, Ui.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "szt1Jdb2AyQZEo1H6f3yeuqkzDGC5Da2Y85j6p3+UHmKlPpeZZWzFxNMhw1drsE3",
  render_errors: [view: Ui.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ui.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
