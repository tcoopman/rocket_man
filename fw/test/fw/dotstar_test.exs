defmodule FwTest.Dotstar do
  use ExUnit.Case

  import Mox

  alias Fw.Dotstar

  setup :set_mox_global
  setup :verify_on_exit!

  test "starting a dotstar" do
    Fw.SPI.Mock
    |> expect(:start_link, fn name, [speed_hz: 10] ->
      assert name == "spidev0.0"
      {:ok, self()}
    end)

    assert {:ok, _pid} = Dotstar.start_link(speed_hz: 10)
  end

  test "red" do
    Fw.SPI.Mock
    |> expect(:start_link, fn _, _ -> {:ok, self()} end)
    |> expect(:transfer, fn pid, command ->
      assert ^pid = self()
      assert <<0, 0, 0, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255>> = command
    end)

    {:ok, _pid} = Dotstar.start_link(speed_hz: 10)
    assert :ok = Dotstar.red(1)
  end
end
