defmodule Fw.Color do
  defmodule RGBA do
    defstruct [:red, :green, :blue, :alpha]
  end

  def transition(steps) when steps > 1 do
    # ColorUtils transforms 360 to wrong value, 359.9 is correct 
    step_size = 359.9 / (steps - 1)
    hues = for n <- 0..(steps - 1), do: step_size * n

    Enum.map(hues, fn hue ->
      ColorUtils.hsv_to_rgb(%ColorUtils.HSV{hue: hue, saturation: 100, value: 100.0})
    end)
    |> Enum.map(fn %ColorUtils.RGB{blue: blue, green: green, red: red} ->
      %RGBA{blue: blue, red: red, green: green, alpha: 1}
    end)
  end
end
