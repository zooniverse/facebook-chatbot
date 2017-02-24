defmodule Chatbot.Panoptes do
  use HTTPoison.Base

  @endpoint "https://panoptes.zooniverse.org/api"

  def get_subjects(workflow_id, limit \\ 5) do
    get!("/subjects/queued?workflow_id=#{workflow_id}&page_size=#{limit}").body["subjects"]
  end

  def classify(project_id, workflow_id, subject_id, value) do
    # {"classifications":{"annotations":[{"value":0,"task":"init"}],"metadata":{"workflow_version":"2.5","started_at":"2017-02-24T15:40:41.666Z","user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3) AppleWebKit/602.4.8 (KHTML, like Gecko) Version/10.0.3 Safari/602.4.8","user_language":"en","utc_offset":"0","subject_dimensions":[{"naturalWidth":480,"naturalHeight":480,"clientWidth":480,"clientHeight":480}],"session":"fe75bfebfe04552b2311d90dc99444a58ff71bc35134654ac7a6221f2d045bb9","finished_at":"2017-02-24T15:40:46.045Z","viewport":{"width":1210,"height":785}},"links":{"project":"764","workflow":"2303","subjects":["3068516"]},"completed":true}} 

    post! "/classifications", %{
      classifications: %{
        annotations: [%{task: "init", value: value}],
        completed: true,
        metadata: %{
          workflow_version: "2.5",
          user_language: "en",
          user_agent: "Facebook Messenger",
          started_at: DateTime.utc_now |> DateTime.to_iso8601,
          finished_at: DateTime.utc_now |> DateTime.to_iso8601
        },
        links: %{
          project: project_id,
          workflow: workflow_id,
          subjects: [subject_id]
        }
      }
    }
  end

  def process_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    headers ++ ["Accept": "application/vnd.api+json; version=1",
                "Content-Type": "application/json"]
  end

  def process_request_body(body) do
    body |> Poison.encode!
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end
end
