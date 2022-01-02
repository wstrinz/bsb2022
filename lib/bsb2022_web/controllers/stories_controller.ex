defmodule Bsb2022Web.StoriesController do
  use Bsb2022Web, :controller

  def index(conn, _params) do
    response = HTTPoison.get!("https://feeds.feedblitz.com/marginalrevolution")
    {:ok, rss_result} = FastRSS.parse(response.body)

    example_stories =
      rss_result
      |> Map.get("items")
      |> Enum.with_index()
      |> Enum.map(fn {story, idx} ->
        Map.merge(story, %{"id" => idx, "read" => false})
      end)

    json(
      conn,
      example_stories
    )
  end
end
