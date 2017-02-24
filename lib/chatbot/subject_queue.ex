defmodule Chatbot.SubjectQueue do
  use GenServer

  alias Chatbot.Panoptes

  @name Chatbot.SubjectQueue
  @workflow_id 2303
  @min_size 5

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  def get do
    GenServer.call(@name, :get)
  end

  def fetch do
    GenServer.cast(@name, :fetch)
  end

  ### Server callbacks

  def init(:ok) do
    subjects = Panoptes.get_subjects(@workflow_id)
    {:ok, subjects}
  end

  def handle_call(:get, _from, []) do
    subject = Panoptes.get_subjects(@workflow_id, 1)[0]
    {:reply, subject, []}
  end

  def handle_call(:get, _from, [subject | subjects]) do
    if length(subjects) < @min_size do
      fetch()
    end

    {:reply, subject, subjects}
  end

  def handle_cast(:fetch, subjects) do
    {:noreply, subjects ++ Panoptes.get_subjects(@workflow_id)}
  end
end
