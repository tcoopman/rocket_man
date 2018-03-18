defmodule Fw.Color do
    def gradient(steps) do
        step_size = 359.9 / (steps - 1) # ColorUtils transforms 360 to wrong value, 359.9 is correct 
        hues = for n <- 0..(steps - 1), do: step_size * n

        colors = Enum.map(hues, fn hue -> 
            ColorUtils.hsv_to_rgb(%ColorUtils.HSV{hue: hue, saturation: 100, value: 100.0})
        end)
        |> Enum.map(fn %ColorUtils.RGB{blue: blue, green: green, red: red} -> 
            %{blue: blue, red: red, green: green}
        end)
    end
end