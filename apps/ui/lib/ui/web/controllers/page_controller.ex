defmodule Ui.Web.PageController do
  use Ui.Web, :controller

  def index(conn, _params) do
    conn
    |> send_file(200,"/root/data.csv")
  end

  def log(conn, _params) do
    conn
    |> send_file(200, "/root/error.log")
  end

  def clean(conn, _params) do
    File.rm("/root/data.csv")
    {:ok, file } = File.open("/root/data.csv", [:write])
    IO.write(file, "id, datetime, albedo, sky, ground, has_fix, latitude, longitude, altitude, satelites, hdop, speed #, gps_data\n")
    File.close(file)
    conn
    |> send_resp(200, "success")
  end

  def clean_log(conn, _params) do
    File.rm("/root/error.log")
    conn
    |> send_resp(200, "success")
  end
end
