defmodule Albedo.Worker do
  @moduledoc """
  A module to read each albedo sensors and log the data
  """

  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def loop(sensor) do
    read_data(sensor)
    # :timer.sleep(1000)
    loop(sensor)
  end

  defp sp510(value) do
    value * 17.5
  end

  defp sp610(value) do
    value * 6.7
  end


  def read_data(sensor) do

    sky = Sensor.read_sky(sensor)
          |> sp510

    ground = Sensor.read_ground(sensor)
             |>sp610

    Logger.info "ground radiation #{inspect(ground)} sky radiation #{inspect(sky)}"

    # read gps
    {:ok, gps} = XGPS.Ports.get_one_position
    Logger.info "GPS: #{inspect(gps)}"

    # write
    {altitude, _unit} = gps.altitude
    {:ok, file} = File.open("/root/data.csv", [:append])
    IO.write(file, "#{gps.date} #{gps.time}, #{albedo(ground,sky)}, #{sky}, #{ground}, #{gps.has_fix}, #{gps.latitude}, #{gps.longitude}, #{altitude}, #{gps.satelites}, #{gps.hdop} #, #{inspect(gps)}\n")
    File.close(file)
  end

  def albedo(ground,sky) do
    case sky do
      0.0 -> nil
      _ -> ground/sky
    end
  end

  def init(_opts) do
    Logger.info "starting Albedo.Worker"
    {:ok, sensor} = Sensor.start_link()
    send(self(), :start)
    {:ok, sensor}
  end

  def handle_info(:start, sensor) do
    Logger.info "Start looping"
    Nerves.Leds.set green: :slowblink
    # TODO if not file write header
    loop(sensor)
  end
end
