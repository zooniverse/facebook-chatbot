defmodule Chatbot.Router do
  use Chatbot.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Chatbot do
    pipe_through :api

    get "/webhook", WebhookController, :get
    post "/webhook", WebhookController, :post
  end
end
