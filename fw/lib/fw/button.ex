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
    # Fw.Dotstar.red(140)
    spawn fn ->
        colors = Fw.Color.gradient(500)
        Enum.each(colors, fn %{blue: blue, green: green, red: red} -> 
            color_command = for _ <- 1..125, into: <<>>, do: <<255, blue, green, red>>
            command = <<0, 0, 0, 0>> <> color_command
            Fw.Dotstar.custom(1, command)
            Process.sleep(10)
        end)
    end
    {:noreply, state}
  end

  def handle_info({:gpio_interrupt, _, :falling}, state) do
    # Fw.Dotstar.off(140)
    {:noreply, state}
  end
end
