defmodule Chatbot.Inbox do
  use GenServer

  alias Chatbot.Facebook

  @name Chatbot.Inbox

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def process(%{"message" => message, "sender" => %{"id" => sender_id}}) do
    GenServer.cast(@name, {:message, message, sender_id})
  end

  def process(event) do
    IO.inspect("Unknown event:")
    IO.inspect(event)
  end

  ### Server callbacks

  def init(:ok) do
    {:ok, nil}
  end

  def handle_cast({:message, %{"quick_reply" => %{"payload" => payload}}, sender_id}, state) do
    case payload do
      "START_CLASSIFYING" ->
        send_image_task_to(sender_id)
      action ->
        case Regex.run(~r/CLASSIFY_(\w+)_(\d+)/, action) do
          nil ->
            IO.inspect({:unknown_action, action})
          [_, "SKIP", subject_id] ->
            Facebook.text(sender_id, "Don't worry, some of these are pretty hard. How about this one?")
            send_image_task_to(sender_id)
          [_, "YES", subject_id] ->
            Facebook.text(sender_id, "Thanks for your help. Here's another one:")
            save_to_panoptes(764, 2303, subject_id, 0)
            send_image_task_to(sender_id)
          [_, "NO", subject_id] ->
            Facebook.text(sender_id, "Thanks for your help. Here's another one:")
            save_to_panoptes(764, 2303, subject_id, 1)
            send_image_task_to(sender_id)
          [_, "INTERFERENCE", subject_id] ->
            Facebook.text(sender_id, "Thanks for your help. Here's another one:")
            save_to_panoptes(764, 2303, subject_id, 2)
            send_image_task_to(sender_id)
          [_, annotation, subject_id] ->
            IO.inspect({:save, annotation, subject_id})
        end
    end
    # "CLASSIFY_SKIP" ->
    #   Facebook.text(sender_id, "Don't worry, some of these are pretty hard. How about this one?")
    #   send_image_task_to(sender_id)
    # "CLASSIFY_YES" ->
    #   Facebook.text(sender_id, "Thanks for your help. Here's another one:")
    #   send_image_task_to(sender_id)
    # "CLASSIFY_NO" ->
    #   Facebook.text(sender_id, "Thanks for your help. Here's another one:")
    #   send_image_task_to(sender_id)
    # "CLASSIFY_INTERFERENCE" ->
    #   Facebook.text(sender_id, "Thanks for your help. Here's another one:")
    #   send_image_task_to(sender_id)

    {:noreply, state}
  end

  def handle_cast({:message, %{"text" => "Start classifying"}, sender_id}, state) do
    send_image_task_to(sender_id)
    {:noreply, state}
  end

  def handle_cast({:message, %{"text" => text}, sender_id}, state) do
    buttons = [{"START_CLASSIFYING", "Start classifying"}]
    Facebook.text(sender_id, "I'm not really sure what you mean with that. What would you like to do?", buttons)
    {:noreply, state}
  end

  def send_image_task_to(sender_id) do
    subject = Chatbot.SubjectQueue.get
    id = subject["id"]
    url = get_in(subject, ["locations", Access.at(0), "image/png"])
    buttons = [
      {"CLASSIFY_YES_#{id}", "Yes"},
      {"CLASSIFY_NO_#{id}", "No"},
      {"CLASSIFY_INTERFERENCE_#{id}", "Radio Interference"},
      {"CLASSIFY_SKIP_#{id}", "I don't know"}
    ]

    Facebook.text(sender_id, "Does this look like a pulsar?")
    Facebook.image(sender_id, url, buttons)
  end

  def save_to_panoptes(project_id, workflow_id, subject_id, value) do
    Chatbot.Panoptes.classify(project_id, workflow_id, subject_id, value)
  end
end
