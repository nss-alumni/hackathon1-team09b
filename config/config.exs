# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :nss_til,
  ecto_repos: [NssTil.Repo]

# Configures the endpoint
config :nss_til, NssTilWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "84mN2Ehz7e0MuYLSv3J4MbOnpQwChmV5vl6Q3F7lPOuOXjlc9dEn9xKo1Rx/5tm8",
  render_errors: [view: NssTilWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NssTil.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
