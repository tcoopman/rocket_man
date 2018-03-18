defmodule Fw.DotstarDebug do
  alias Fw.Dotstar

  def test(speed_hz, delay_us) do
    {:ok, _pid} = Dotstar.start_link(speed_hz: speed_hz, delay_us: delay_us)
    blue = <<255, 255, 0, 0>>
    green = <<255, 0, 255, 0>>
    red = <<255, 0, 0, 255>>
    rgb = blue <> green <> red
    Dotstar.red(140)
    Process.sleep(5000)
    Dotstar.off(140)
    Process.sleep(1000)
    Dotstar.custom(1, <<0, 0, 0, 0>>)
    Dotstar.custom(120, <<255, 255, 0, 0>>)
    Process.sleep(5000)
    Dotstar.off(140)
    Dotstar.custom(1, <<0, 0, 0, 0>>)
    Dotstar.custom(120, <<255, 0, 255, 0>>)
    Process.sleep(5000)
    Dotstar.off(140)

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

    Dotstar.release()
  end

  defp test_move(command) do
    Dotstar.move(5, command)
    Process.sleep(2000)
    Dotstar.move(10, command)
    Process.sleep(2000)
    Dotstar.move(20, command)
    Process.sleep(3000)
    Dotstar.move(50, command)
    Process.sleep(7000)
  end

  def transition_colors() do
    colors = Fw.Color.transition(500)

    Enum.each(colors, fn %{blue: blue, green: green, red: red} ->
      color_command = for _ <- 1..125, into: <<>>, do: <<255, blue, green, red>>
      command = <<0, 0, 0, 0>> <> color_command
      Fw.Dotstar.custom(1, command)
      Process.sleep(10)
    end)
  end
end
