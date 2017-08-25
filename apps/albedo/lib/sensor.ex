defmodule Sensor do
  @moduledoc """
  Read from albedo sensors
  """

  use GenServer

  # Client
  def start_link(address) do
    GenServer.start_link(__MODULE__, address)
  end

  def start_link() do
    GenServer.start_link(__MODULE__, 0x48)
  end

  def read_sky(pid) do
    GenServer.call(pid, :read_sky)
  end

  def read_ground(pid) do
    GenServer.call(pid, :read_ground)
  end

  # Server

  def init(address) do
    ADS1115.init("i2c-1", address)
  end

  def handle_call(:read_sky, _from, i2c) do
    {:reply, ADS1115.read(i2c, 0, 16, 8), i2c}
  end

  def handle_call(:read_ground, _from, i2c) do
    {:reply, ADS1115.read(i2c, 3, 16, 8), i2c}
  end

end
