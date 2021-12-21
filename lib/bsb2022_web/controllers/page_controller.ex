defmodule Bsb2022Web.PageController do
  use Bsb2022Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
