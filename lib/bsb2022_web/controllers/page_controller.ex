defmodule Bsb2022Web.PageController do
  use Bsb2022Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def stories(conn, _params) do
    response = HTTPoison.get!("https://feeds.feedblitz.com/marginalrevolution")
    {:ok, rss_result} = FastRSS.parse(response.body)

    json(
      conn,
      rss_result |> Map.get("items") |> List.first() |> Map.take(["title", "author", "content"])
    )
  end
end
