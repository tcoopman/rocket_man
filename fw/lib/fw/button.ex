defmodule Fw.Button do
    use GenServer

    alias ElixirALE.GPIO

    def start_link() do
        GenServer.start_link(__MODULE__, nil)
    end

    def init(nil) do
        {:ok, pid} = GPIO.start_link(17, :input)
        GPIO.set_int(pid, :both)
        {:ok, pid}
    end

    def handle_info({:gpio_interrupt, _, :rising}, state) do
        Fw.DotStar.red(140)
        IO.inspect "red"
        {:noreply, state}
    end
    def handle_info({:gpio_interrupt, _, :falling}, state) do
        Fw.DotStar.off(140)
        IO.inspect "off"
        {:noreply, state}
    end
end