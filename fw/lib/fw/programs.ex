defmodule Fw.Programs do
  defmodule Walker do
    def new(length) do
      %{
        length: length,
        iteration: 0,
        color: %{blue: 255, green: 0, red: 0}
      }
    end

    def execute(%{length: length, iteration: i, color: color}) when i <= length / 2 do
      sleep = 20

      state = %{
        length: length,
        iteration: i + 1,
        color: color
      }

      {command(i, color, length), sleep, state}
    end

    def execute(%{length: length, color: color}) do
      color = switch_color(color)
      sleep = 20

      state = %{
        length: length,
        iteration: 0,
        color: color
      }

      {command(0, color, length), sleep, state}
    end

    defp command(i, color, length) when i == 0 do
      <<0, 0, 0, 0>> <> for(_ <- 1..length, into: <<>>, do: off(color)) <> close()
    end

    defp command(i, color, length) when i <= length / 2 do
      pivot1 = i
      pivot2 = length - i

      case pivot1 < pivot2 do
        true ->
          begin_range = 1..pivot1
          middle_range = (pivot1 + 1)..pivot2
          end_range = (pivot2 + 1)..length

          begin = for _ <- begin_range, into: <<>>, do: colored(color)
          middle = for _ <- middle_range, into: <<>>, do: off(color)
          end_ = for _ <- end_range, into: <<>>, do: colored(color)

          <<0, 0, 0, 0>> <> begin <> middle <> end_ <> close()

        false ->
          <<0, 0, 0, 0>> <> for(_ <- 1..length, into: <<>>, do: colored(color)) <> close()
      end
    end

    defp colored(%{blue: blue, green: green, red: red}), do: <<255, blue, green, red>>
    defp off(_), do: <<255, 0, 0, 0>>
    defp close(), do: for(_ <- 1..5, into: <<>>, do: <<255, 255, 255, 255>>)

    defp switch_color(%{blue: 255}), do: %{blue: 0, green: 255, red: 0}
    defp switch_color(%{green: 255}), do: %{blue: 0, green: 0, red: 255}
    defp switch_color(%{red: 255}), do: %{blue: 255, green: 0, red: 0}
  end

  defmodule WalkerDown do
    def new(length) do
      %{
        length: length,
        iteration: 0,
        up_or_down: :up,
        color: %{blue: 255, green: 0, red: 0}
      }
    end

    def execute(state) do
      length = state.length

      command = command(state.iteration, state.color, state.length)

      state =
        case {state.up_or_down, state.iteration} do
          {:up, i} when i+1 <= length / 2 ->
            state = %{state | iteration: i + 1}

          {:up, i} ->
            state = %{state | iteration: i - 1, up_or_down: :down}

          {:down, i} when i-1 >= 0 ->
            state = %{state | iteration: i - 1}

          {:down, i} ->
            state = %{state | iteration: i + 1, up_or_down: :up, color: switch_color(state.color)}
        end

      {command, 30, state}
    end

    defp command(i, color, length) when i == 0 do
      <<0, 0, 0, 0>> <> for(_ <- 1..length, into: <<>>, do: off(color)) <> close()
    end

    defp command(i, color, length) when i <= length / 2 do
      pivot1 = i
      pivot2 = length - i

      case pivot1 < pivot2 do
        true ->
          begin_range = 1..pivot1
          middle_range = (pivot1 + 1)..pivot2
          end_range = (pivot2 + 1)..length

          begin = for _ <- begin_range, into: <<>>, do: colored(color)
          middle = for _ <- middle_range, into: <<>>, do: off(color)
          end_ = for _ <- end_range, into: <<>>, do: colored(color)

          <<0, 0, 0, 0>> <> begin <> middle <> end_ <> close()

        false ->
          <<0, 0, 0, 0>> <> for(_ <- 1..length, into: <<>>, do: colored(color)) <> close()
      end
    end

    defp colored(%{blue: blue, green: green, red: red}), do: <<255, blue, green, red>>
    defp off(_), do: <<255, 0, 0, 0>>
    defp close(), do: for(_ <- 1..5, into: <<>>, do: <<255, 255, 255, 255>>)

    defp switch_color(%{blue: 255}), do: %{blue: 0, green: 255, red: 0}
    defp switch_color(%{green: 255}), do: %{blue: 0, green: 0, red: 255}
    defp switch_color(%{red: 255}), do: %{blue: 255, green: 0, red: 0}
  end
end
