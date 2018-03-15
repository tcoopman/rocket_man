defmodule Fw.DotstarDebug do
    alias Fw.DotStar

    def test(speed_hz, delay_us) do
        {:ok, _pid} = DotStar.start_link([speed_hz: speed_hz, delay_us: delay_us])
        blue = <<255, 255, 0, 0>>
        green = <<255, 0, 255, 0>>
        red = <<255, 0, 0, 255>>
        rgb = blue <> green <> red
        DotStar.red(140)
        Process.sleep(5000)
        DotStar.off(140)
        Process.sleep(1000)
        DotStar.custom(1, <<0, 0, 0, 0>>)
        DotStar.custom(120, <<255, 255, 0, 0>>)
        Process.sleep(5000)
        DotStar.off(140)
        DotStar.custom(1, <<0, 0, 0, 0>>)
        DotStar.custom(120, <<255, 0, 255, 0>>)
        Process.sleep(5000)
        DotStar.off(140)

        # test_move(blue)
        # test_move(green)
        test_move(red)
        test_move(blue <> green <> red)
        test_move(red <> blue <> green)
        test_move(blue <> red <> green)
        test_move(red <> red)
        test_move(red <> red <> blue <> blue <> green <> green)
        test_move(red <> red <> red <> blue <> blue <> blue <> green <> green <> green)
        test_move(red <> blue <> red <> blue <> red <> blue <> red <> blue <> red)

        DotStar.release()
    end

    defp test_move(command) do
        DotStar.move(5, command)
        Process.sleep(2000)
        DotStar.move(10, command)
        Process.sleep(2000)
        DotStar.move(20, command)
        Process.sleep(3000)
        DotStar.move(50, command)
        Process.sleep(7000)
    end
end