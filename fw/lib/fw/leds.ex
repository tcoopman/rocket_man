defmodule Fw.Leds do
    use GenServer

    require Logger

    alias ElixirALE.GPIO

    def start_link() do
        GenServer.start_link(__MODULE__, nil, name: :leds)
    end

    def init(nil) do
        {:ok, red_led_pid} = GPIO.start_link(18, :output)
        {:ok, blue_led_pid} = GPIO.start_link(23, :output)
        state = [red_led_pid, blue_led_pid]
        start_leds()
        {:ok, state}
    end

    def turn_off() do
        GenServer.call(:leds, :led_off)
    end

    def handle_call(:led_off, _from, state) do
        Enum.each(state, &turn_led_off/1)
        {:reply, :ok, state}
    end

    def handle_info(:leds, state) do
        Enum.each(state, &turn_led_on/1)

        {:noreply, state}
    end

    defp start_leds do
        Process.send_after(self(), :leds, 1)
    end

    defp turn_led_on(led) do
        Logger.debug("Turning pin ON")
        GPIO.write(led, 1)
    end

    defp turn_led_off(led) do
        Logger.debug("Turning pin OFF")
        GPIO.write(led, 0)
    end
end