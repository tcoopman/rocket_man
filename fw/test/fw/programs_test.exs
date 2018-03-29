defmodule Fw.ProgramsTest do
    use ExUnit.Case, async: true

    alias Fw.Programs.Walker

    describe "Walker tests"  do
        test "start is all off" do
            state = Walker.new(10)
            {command, sleep, _state} = Walker.execute(state)

            assert 20 = sleep
            expected = <<0, 0, 0, 0>> <> (for _ <- 1..10, into: <<>>, do: <<255, 0, 0, 0>>) <> close()
            assert expected == command
        end

        test "1 on" do
            state = Walker.new(4)
            {command, _sleep, _state} = Walker.execute(%{state | iteration: 1})

            expected = <<0, 0, 0, 0>> <> <<255, 255, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 0, 0>> <> close()
            assert expected == command
        end

        test "all on" do
            state = Walker.new(4)
            {command, _sleep, _state} = Walker.execute(%{state | iteration: 2})

            expected = <<0, 0, 0, 0>> <> <<255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0>> <> close()
            assert expected == command
        end

        test "restart after half" do
            state = Walker.new(4)
            {command, _sleep, state} = Walker.execute(%{state | iteration: 3})
            expected = <<0, 0, 0, 0>> <> (for _ <- 1..4, into: <<>>, do: <<255, 0, 0, 0>>) <> close()
            assert expected == command
            assert 0 = state.iteration
            assert %{blue: 0, green: 255, red: 0} = state.color
        end

        test "120" do
            state = Walker.new(120)
            {command, _sleep, state} = Walker.execute(%{state | iteration: 40})
            chunked = command |> :binary.bin_to_list |> Enum.chunk_every(4)

            start = Enum.take(chunked, 1) |> :binary.list_to_bin
            assert <<0, 0, 0, 0>> = start

            #expect 40 blues, 40 empty, 40 blues

            chunked = Enum.drop(chunked, 1)
            blues = Enum.take(chunked, 40)
            Enum.each(blues, fn blue ->
                assert <<255, 255, 0, 0>> = :binary.list_to_bin(blue)
            end)

            chunked = Enum.drop(chunked, 40)
            offs = Enum.take(chunked, 40)
            Enum.each(offs, fn off ->
                assert <<255, 0, 0, 0>> = :binary.list_to_bin(off)
            end)

            chunked = Enum.drop(chunked, 40)
            blues = Enum.take(chunked, 40)
            Enum.each(blues, fn blue ->
                assert <<255, 255, 0, 0>> = :binary.list_to_bin(blue)
            end)
        end

    end
    defp close(), do: for _ <- 1..5, into: <<>>, do: <<255, 255, 255, 255>>
end