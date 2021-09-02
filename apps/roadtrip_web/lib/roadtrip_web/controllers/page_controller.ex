defmodule RoadtripWeb.PageController do
  use RoadtripWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
