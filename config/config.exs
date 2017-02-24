# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chatbot,
  ecto_repos: [Chatbot.Repo]

# Configures the endpoint
config :chatbot, Chatbot.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s1OET/I/qGBe6gwaa95L7VjfrbkZvBjhNtv/pVf0jczms4fJn6VJWIr8qoG180oJ",
  render_errors: [view: Chatbot.ErrorView, accepts: ~w(json)],
  pubsub: [name: Chatbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
