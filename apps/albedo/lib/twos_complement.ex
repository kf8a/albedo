defmodule TwosComplement do
  @moduledoc """
  A module to convert 2's complement numbers to integers
  """
  use Bitwise

  @doc """
  Converts a byte to an integer

  ## Examples

    iex>  TwosComplement.decode8( << 42 >> )
    42

    iex> TwosComplement.decode8( << 254 >> )
    -1
  """
  def decode8(<< sign :: 1, rest :: bitstring >>) do
    << number >> = << << sign :: 1 >> :: bitstring, rest :: bitstring >>
    case sign do
      0 ->
        number
      1 ->
        Bitwise.bxor(number, 0xFF) * -1
    end
  end

  @doc """
  Convert two bytes to a 16 bit integer

  ## Examples

    iex> TwosComplement.decode16( << 127, 0 >> )
    32512

    iex> TwosComplement.decode16( << 255, 254 >> )
    -1


  """
  def decode16(<< sign :: 1, rest :: bitstring >>) do
    << number :: unsigned-16 >> = << << sign :: 1 >> :: bitstring, rest :: bitstring >>
    case sign do
      0 ->
        number
      1 ->
        Bitwise.bxor(number, 0xFFFF) * -1
    end
  end
end
