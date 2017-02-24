defmodule Chatbot.WebhookController do
  use Chatbot.Web, :controller

  alias Chatbot.Webhook

  def index(conn, _params) do
    webhooks = Repo.all(Webhook)
    render(conn, "index.json", webhooks: webhooks)
  end

  def create(conn, %{"webhook" => webhook_params}) do
    changeset = Webhook.changeset(%Webhook{}, webhook_params)

    case Repo.insert(changeset) do
      {:ok, webhook} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", webhook_path(conn, :show, webhook))
        |> render("show.json", webhook: webhook)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Chatbot.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    webhook = Repo.get!(Webhook, id)
    render(conn, "show.json", webhook: webhook)
  end

  def update(conn, %{"id" => id, "webhook" => webhook_params}) do
    webhook = Repo.get!(Webhook, id)
    changeset = Webhook.changeset(webhook, webhook_params)

    case Repo.update(changeset) do
      {:ok, webhook} ->
        render(conn, "show.json", webhook: webhook)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Chatbot.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    webhook = Repo.get!(Webhook, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(webhook)

    send_resp(conn, :no_content, "")
  end
end
