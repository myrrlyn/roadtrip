defmodule RoadtripWeb.PageControllerTest do
  use RoadtripWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Roadtrip!"
  end
end
