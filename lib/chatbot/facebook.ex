defmodule Chatbot.Facebook do
  use HTTPoison.Base

  @endpoint "https://graph.facebook.com/v2.6"

  def text(recipient, text, buttons \\ []) do
    call_api %{
      recipient: %{id: recipient},
      message: %{text: text},
      quick_replies: quick_replies(buttons)
    }
  end

  def image(recipient, url, buttons \\ []) do
    call_api %{
      recipient: %{id: recipient},
      message: %{
        attachment: %{type: "image", payload: %{url: url}},
        quick_replies: quick_replies(buttons)
      }
    }
  end

  defp make_button({payload, title}) do
    %{type: "postback", title: title, payload: payload}
  end

  defp quick_replies(buttons) do
    Enum.map buttons, fn {key, text} ->
      %{content_type: "text", title: text, payload: key}
    end
  end

  def process_url(url) do
    @endpoint <> url
  end

  def call_api(data) do
    headers = [{"Content-Type", "application/json"}]
    body = Poison.encode!(data)
    options = [params: [{"access_token", System.get_env("MESSENGER_PAGE_ACCESS_TOKEN")}]]

    IO.puts("Sending message")
    IO.inspect(body)
    case post("/me/messages", body, headers, options) do
      {:ok, response} ->
        IO.puts("Sucessfully sent")
        IO.inspect(response)
      {:error, reason} ->
        IO.puts("Failed to send")
        IO.inspect(reason)
    end
  end
end
