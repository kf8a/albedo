defmodule TwosComplementTest do
  use ExUnit.Case
  doctest TwosComplement

  test "converts 8 bit positive patterns to integer" do
    assert TwosComplement.decode8( << 127 >>) == 127
  end

  test "convert 253 to -2" do
    assert TwosComplement.decode8(<< 253 >>) == -2
  end

  test "convert 16 bit positive pattern to integer" do
    assert TwosComplement.decode16(<< 17, 0 >>) == 4352
  end
  test "convert 16 bit negative pattern to integer" do
    assert TwosComplement.decode16( << 255,  253 >> )  == -2
  end
end
