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
    :timer.sleep(500)
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
    # {altitude | _unit} = gps.altitude
    {:ok, file} = File.open("/root/data.csv", [:append, :sync])
    IO.write(file, "#{gps.date} #{gps.time}, #{albedo(ground,sky)}, #{sky}, #{ground}, #{gps.has_fix}, #{gps.latitude}, #{gps.longitude}, #{altitude(gps.altitude)}, #{gps.satelites}, #{gps.hdop}, #{gps.speed} #, #{inspect(gps)}\n")
    File.close(file)
  end

  def altitude({altitude, _rest}) do
    altitude
  end

  def altitude({altitude}) do
    altitude
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
    Nerves.Leds.set green: :fastblink
    set_clock()
    Logger.info "Datetime set"
    Nerves.Leds.set green: :slowblink
    loop(sensor)
  end

  def wait_for_fix() do
    :timer.sleep(1000)
    # read gps
    {:ok, gps} = XGPS.Ports.get_one_position
    Logger.info "GPS: #{inspect(gps)}"
    case gps.has_fix do
      true -> gps
      _ -> wait_for_fix()
    end
  end

  def set_clock() do
    gps = wait_for_fix()
    [time | _rest]  = String.split("#{gps.date} #{gps.time}",".")
    System.cmd("/bin/date", [time])
  end
end
