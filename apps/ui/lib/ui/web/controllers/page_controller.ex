defmodule Ui.Web.PageController do
  use Ui.Web, :controller

  def index(conn, _params) do
    conn
    |> send_file(200,"/root/data.csv")
  end

  def clean(conn, _params) do
    {:ok, file } = File.open("/root/data.csv", [:write])
    IO.write(file, "datetime, albedo, sky, ground, has_fix, latitude, longitude, altitude, satelites, hdop #, gps_data\n")
    File.close(file)
    conn
    |> send_resp(200, "success")
  end
end
