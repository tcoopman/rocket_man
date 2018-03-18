defmodule Fw.Button do
  use GenServer

  @gpio Application.fetch_env!(:ale, :gpio)

  @doc """
  Starts a new button listener on `gpio` port.

  It will send a `:button_clicked` message to all topics registered under `topic_name`
  """
  def start_link([topic_name: _, pin: _] = opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(topic_name: topic_name, pin: pin) do
    {:ok, pid} = @gpio.start_link(pin, :input)
    @gpio.set_int(pid, :both)
    {:ok, %{gpio_pid: pid, topic_name: topic_name, ignore: false}}
  end

  @impl GenServer
  def handle_info({:gpio_interrupt, _, :rising}, %{topic_name: topic_name, ignore: false} = state) do
    Registry.dispatch(:fw_pubsub, topic_name, fn entries ->
      for {pid, _} <- entries, do: send(pid, :button_clicked)
    end)

    # spawn(fn ->
    #   colors = Fw.Color.transition(500)

    #   Enum.each(colors, fn %{blue: blue, green: green, red: red} ->
    #     color_command = for _ <- 1..125, into: <<>>, do: <<255, blue, green, red>>
    #     command = <<0, 0, 0, 0>> <> color_command
    #     Fw.Dotstar.custom(1, command)
    #     Process.sleep(10)
    #   end)
    # end)

    state = %{state | ignore: true}
    start_ignore_timer()

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:gpio_interrupt, _, :falling}, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:gpio_interrupt, _, _}, %{ignore: true} = state), do: {:noreply, state}

  @impl GenServer
  def handle_info(:lift_ignore, state) do
    {:noreply, %{state | ignore: false}}
  end

  defp start_ignore_timer() do
    Process.send_after(self(), :lift_ignore, 100)
  end
end
