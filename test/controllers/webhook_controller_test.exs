defmodule Chatbot.WebhookControllerTest do
  use Chatbot.ConnCase

  alias Chatbot.Webhook
  @valid_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, webhook_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    webhook = Repo.insert! %Webhook{}
    conn = get conn, webhook_path(conn, :show, webhook)
    assert json_response(conn, 200)["data"] == %{"id" => webhook.id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, webhook_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, webhook_path(conn, :create), webhook: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Webhook, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, webhook_path(conn, :create), webhook: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    webhook = Repo.insert! %Webhook{}
    conn = put conn, webhook_path(conn, :update, webhook), webhook: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Webhook, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    webhook = Repo.insert! %Webhook{}
    conn = put conn, webhook_path(conn, :update, webhook), webhook: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    webhook = Repo.insert! %Webhook{}
    conn = delete conn, webhook_path(conn, :delete, webhook)
    assert response(conn, 204)
    refute Repo.get(Webhook, webhook.id)
  end
end
