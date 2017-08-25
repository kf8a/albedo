defmodule Albedo.Worker do
  @moduledoc """
  A module to read each albedo sensors and log the data
  """

  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [], [])
  end

  def loop(state) do
    read_data(state)
    :timer.sleep(50)
    loop(state)
  end

  defp sp510(value) do
    value * 17.5
  end

  defp sp610(value) do
    value * 6.7
  end


  def read_data(state) do

    sensor = state[:sensor_pid]
    ids = state[:id_pid]

    sky = sensor
          |> Sensor.read_sky
          |> sp510

    ground = sensor
             |> Sensor.read_ground
             |> sp610

    # Logger.debug "ground radiation #{inspect(ground)} sky radiation #{inspect(sky)}"

    # read gps
    {:ok, gps} = XGPS.Ports.get_one_position
    # Logger.debug "GPS: #{inspect(gps)}"

    if slow?(gps) do
      Albedo.Id.start(ids, {gps.latitude, gps.longitude, gps.date, gps.time})
    else
      Albedo.Id.pause(ids)
    end

    # write
    # {altitude | _unit} = gps.altitude
    {:ok, file} = File.open("/root/data.csv", [:append, :sync])
    timestamp = DateTime.to_iso8601(DateTime.utc_now)
    IO.write(file, "#{Albedo.Id.get(ids)}, #{timestamp}, #{albedo(ground,sky)}, #{sky}, #{ground}, #{gps.has_fix}, #{gps.latitude}, #{gps.longitude}, #{altitude(gps.altitude)}, #{gps.satelites}, #{gps.hdop}, #{gps.speed} #, #{inspect(gps)}\n")
    File.close(file)
  end

  def slow?(gps) do
    gps.has_fix && gps.speed < 1
  end

  def altitude({altitude, _rest}) do
    altitude
  end

  def altitude({altitude}) do
    altitude
  end

  def albedo(ground, sky) do
    case sky do
      0.0 -> nil
      _ -> ground / sky
    end
  end

  def init(_opts) do
    Logger.info "starting Albedo.Worker"
    {:ok, sensor} = Sensor.start_link()
    {:ok, id_server} = Albedo.Id.start_link()
    send(self(), :start)
    {:ok, [sensor_pid: sensor, id_pid: id_server]}
  end

  def handle_info(:start, state) do
    Logger.info "Start looping"
    Nerves.Leds.set green: :fastblink
    set_clock()
    Logger.info "Datetime set"
    Nerves.Leds.set green: :slowblink
    loop(state)
  end

  def wait_for_fix() do
    :timer.sleep(1000)
    {:ok, gps} = XGPS.Ports.get_one_position
    case gps.has_fix do
      true -> gps
      _ -> wait_for_fix()
    end
  end

  def set_clock() do
    gps = wait_for_fix()
    [time | _rest]  = String.split("#{gps.date} #{gps.time}", ".")
    System.cmd("/bin/date", [time])
  end
end
