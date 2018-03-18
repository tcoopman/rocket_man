defmodule FwTest.Dotstar do
    use ExUnit.Case

    import Mox

    alias Fw.Dotstar

    setup :set_mox_global
    setup :verify_on_exit!

    test "starting a dotstar" do
        Fw.SPIMock
        |> expect(:start_link, fn name, _options -> 
            assert name == "spidev0.0"
            {:ok, self()}
        end)
        assert {:ok, _pid} = Dotstar.start_link([])
    end
end