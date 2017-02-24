defmodule Chatbot.Router do
  use Chatbot.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Chatbot do
    pipe_through :api
  end
end
