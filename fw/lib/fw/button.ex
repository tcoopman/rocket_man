defmodule Fw.Button do
  use GenServer

  @gpio Application.fetch_env!(:ale, :gpio)

  @doc """
  Starts a new button listener on `gpio` port.

  It will send a `:button` message to all topics registered under `topic_name`
  """
  def start_link([topic_name: _, pin: _] = opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(topic_name: topic_name, pin: pin) do
    {:ok, pid} = @gpio.start_link(pin, :input)
    @gpio.set_int(pid, :both)
    {:ok, pid}
  end

  @impl GenServer
  def handle_info({:gpio_interrupt, _, :rising}, state) do
    spawn(fn ->
      colors = Fw.Color.transition(500)

      Enum.each(colors, fn %{blue: blue, green: green, red: red} ->
        color_command = for _ <- 1..125, into: <<>>, do: <<255, blue, green, red>>
        command = <<0, 0, 0, 0>> <> color_command
        Fw.Dotstar.custom(1, command)
        Process.sleep(10)
      end)
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:gpio_interrupt, _, :falling}, state) do
    {:noreply, state}
  end
end
