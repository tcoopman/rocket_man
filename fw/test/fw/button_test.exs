defmodule FwTest.ButtonTest do
  use ExUnit.Case

  import Mox

  alias Fw.Button

  setup :set_mox_global
  setup :verify_on_exit!

  describe "pressing a button" do
    test "starting a button" do
      Fw.GPIO.Mock
      |> expect(:start_link, fn pin, direction ->
        assert 15 == pin
        assert :input == direction
        {:ok, self()}
      end)
      |> expect(:set_int, fn pid, int_direction ->
        assert pid == self()
        assert :both == int_direction
      end)

      assert {:ok, pid} = Button.start_link(topic_name: "button", pin: 15)
    end
  end
end
