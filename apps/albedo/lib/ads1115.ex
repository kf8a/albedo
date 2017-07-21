defmodule ADS1115 do
  @moduledoc """
  Function to read and write to a Texas Instruments ADS115 https://cdn-shop.adafruit.com/datasheets/ads1115.pdf
  """

  alias ElixirALE.I2C

  use Bitwise
  require Logger

  # Register and other configuration values:
  @ads1x15_default_address         0x48
  @ads1x15_pointer_conversion      <<0x00>>
  @ads1x15_pointer_config          0x01
  @ads1x15_pointer_low_threshold   0x02
  @ads1x15_pointer_high_threshold  0x03
  @ads1x15_config_os_single        << 0x80, 0x00>>
  @ads1x15_config_mux_offset       12

  # Maping of gain values to config register values.
  @ads1x15_config_gain %{0.3 =>  0x0000,
                         1 =>    0x0200,
                         2 =>    0x0400,
                         4 =>    0x0600,
                         8 =>    0x0800,
                         16 =>   0x0A00}
  @ads1x15_config_mode_continuous  0x0000
  @ads1x15_config_mode_single      0x0100
  # Mapping of data/sample rate to config register values for ADS1115 (slower).
  @data_rate_config %{8 =>    0x0000,
                      16 =>   0x0020,
                      32 =>   0x0040,
                      64 =>   0x0060,
                      128 =>  0x0080,
                      250 =>  0x00A0,
                      475 =>  0x00C0,
                      860 =>  0x00E0}

  @ads1x15_config_comp_window      0x0010
  @ads1x15_config_comp_active_high 0x0008
  @ads1x15_config_comp_latching    0x0004
  @ads1x15_config_comp_que [{1, 0x0000},
                            {2, 0x0001},
                            {4, 0x0002}]
  @ads1x15_config_comp_que_disable 0x0003


  @doc """
  Initialize the I2C sensor

  Example: ADS1115.init("i2c-1", 0x48)

  Returns: {:ok, pid}
  """
  def init(bus, address) do
    I2C.start_link(bus, address)
  end

  @doc """
  Perform an ADC read with the provided mux, gain, data_rate, and mode
  values.  Takes the pid of an ElixirALE.i2c connection. Returns the signed integer result of the read.
  """
  def read(pid, mux, gain, data_rate) do
    config = ads_config(@ads1x15_config_mode_single, mux, gain, data_rate)
    # Break 16 bit value into two 8 bit big endian
    bit0 = (config >>> 8) &&& 0xFF
    bit1 = config &&& 0xFF
    command = << @ads1x15_pointer_config , bit0, bit1 >>

    # Write to config register
    Logger.debug "command  #{inspect(command , binaries: :as_binaries, base: :binary)}"
    status = I2C.write(pid, command)
    Logger.debug("status: #{status}")

    sleep(data_rate)
     # Read from conversion register and convert to number
    TwosComplement.decode16(read_conversion_register(pid))
    |> mv(gain)
  end

  def sleep(data_rate) do
    # sleep for 1/dat_rate+ 0.0001) seconds
    (1/data_rate + 0.0001) * 1000
    |> Float.ceil
    |> Kernel.trunc
    |> :timer.sleep
  end

  def read_conversion_register(pid) do
    I2C.write_read(pid, @ads1x15_pointer_conversion, 2)
  end

  def mux_value(mux) do
    (mux &&& 0x7) <<< @ads1x15_config_mux_offset
  end

  def ads_config(mode, mux, gain, data_rate) do
    mux_config = mux_value(mux)
    # @ads1x15_config_mode_single
    0x8000
      |> Bitwise.bor(mux_config)
      |> Bitwise.bor(@ads1x15_config_gain[gain])
      |> Bitwise.bor(mode)
      |> Bitwise.bor(@data_rate_config[data_rate])
      |> Bitwise.bor(@ads1x15_config_comp_que_disable)
  end

  defp mv(value, gain) do
    case gain do
      16 ->  value/32768.0 * 256
      8 -> value/32768.0 * 512
      4 -> value/32768.0 * 1024
      2 -> value/32768.0 * 2048
      1 -> value/32768.0 * 4096
      0.3 -> value/32768.0 * 6144
    end
  end
end
