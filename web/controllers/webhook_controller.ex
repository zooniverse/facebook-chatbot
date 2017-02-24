defmodule Chatbot.WebhookController do
  use Chatbot.Web, :controller

  alias Chatbot.Webhook

  def get(conn, params) do
    if params["hub.mode"] == "subscribe" && params["hub.verify_token"] == @validation_token do
      conn |> send_resp(200, params["hub.challenge"])
    else
      conn |> send_resp(403, "")
    end
  end

  def post(conn, params) do
    if params["object"] == "page" do
      for pageEntry <- params["entry"] do
        for event <- pageEntry["messaging"] do
          Chatbot.Inbox.process(event)
        end
      end
    end

    conn |> send_resp(200, "")
  end

end
