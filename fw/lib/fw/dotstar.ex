defmodule Fw.DotStar do
    use GenServer

    require Logger

    alias ElixirALE.SPI

    def start_link() do
        GenServer.start_link(__MODULE__, nil, name: :dotstar)
    end

    def init(nil) do
        {:ok, pid} = SPI.start_link("spidev0.0", speed_hz: 32000000)
        {:ok, pid}
    end

    def red(nb) do
        GenServer.call(:dotstar, {:red, nb})
    end

    def off(nb) do
        GenServer.call(:dotstar, {:off, nb})
    end

    def custom(nb, binary) do
        GenServer.call(:dotstar, {:custom, nb, binary})
    end

    def handle_call({:red,nb}, _from, pid) do
        red_command = for _ <- 1..nb, into: <<>>, do: <<255, 0, 0, 255>>
        full_command = start_frame() <> red_command <> end_frame()

        send_command(full_command,pid)

        {:reply, :ok, pid}
    end
    def handle_call({:off,nb}, _from, pid) do
        off_command = for _ <- 1..nb, into: <<>>, do: <<224, 0, 0, 0>>
        full_command = start_frame() <> off_command <> end_frame()
        
        send_command(full_command,pid)

        {:reply, :ok, pid}
    end
    def handle_call({:custom, nb, binary}, _from, pid) do
        command = for _ <- 1..nb, into: <<>>, do: binary

        send_command(command,pid)
        {:reply, :ok, pid}
    end

    defp start_frame() do
        <<0,0,0,0>>
    end

    defp end_frame() do
        <<255,255,255,255,255,255,255,255>>
    end

    defp send_command(command, pid) do
        command
        |> :binary.bin_to_list
        |> Enum.each(fn byte ->
            _ = SPI.transfer(pid, :binary.encode_unsigned(byte))
        end)
    end
end