defmodule Fw.Program do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(_) do
    Registry.register(:fw_pubsub, "button17", [])
    {:ok, %{state: :state1, task: nil}}
  end

  @impl GenServer
  def handle_info(:button_clicked, %{state: :state1} = state) do
    :ok = kill(state.task)

    pid =
      spawn(fn ->
        colors = Fw.Color.transition(500)

        Enum.each(colors, fn %{blue: blue, green: green, red: red} ->
          color_command = for _ <- 1..125, into: <<>>, do: <<255, blue, green, red>>
          command = <<0, 0, 0, 0>> <> color_command
          Fw.Dotstar.custom(1, command)
          Process.sleep(10)
        end)
      end)

    {:noreply, %{state | state: :state2, task: pid}}
  end

  @impl GenServer
  def handle_info(:button_clicked, %{state: :state2} = state) do
    :ok = kill(state.task)

    pid =
      spawn(fn ->
        Enum.each(1..320, fn i ->
          brightness = rem(i, 32)
          color_command = for _ <- 1..125, into: <<>>, do: << <<7::3>>, <<brightness::5>>, 255, 0, 0 >>
          command = <<0, 0, 0, 0>> <> color_command
          Fw.Dotstar.custom(1, command)
          Process.sleep(100)
        end)
      end)

    {:noreply, %{state | state: :state3, task: pid}}
  end

  @impl GenServer
  def handle_info(:button_clicked, state) do
    :ok = kill(state.task)
    Fw.Dotstar.off(140)

    {:noreply, %{state | state: :state1, task: nil}}
  end

  defp kill(nil), do: :ok

  defp kill(pid) do
    true = Process.exit(pid, :kill)
    :ok
  end
end
