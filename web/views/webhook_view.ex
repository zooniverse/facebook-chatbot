defmodule Chatbot.WebhookView do
  use Chatbot.Web, :view

  def render("index.json", %{webhooks: webhooks}) do
    %{data: render_many(webhooks, Chatbot.WebhookView, "webhook.json")}
  end

  def render("show.json", %{webhook: webhook}) do
    %{data: render_one(webhook, Chatbot.WebhookView, "webhook.json")}
  end

  def render("webhook.json", %{webhook: webhook}) do
    %{id: webhook.id}
  end
end
