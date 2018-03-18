defmodule Fw.Dotstar do
  use GenServer

  require Logger

  @spi Application.fetch_env!(:ale, :spi)

  def start_link(speed_hz: speed_hz) do
    GenServer.start_link(__MODULE__, [speed_hz: speed_hz], name: :dotstar)
  end

  @impl GenServer
  def init(opts) do
    {:ok, pid} = @spi.start_link("spidev0.0", opts)
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

  def cycle_start(nb) do
    GenServer.call(:dotstar, {:cycle_start, nb})
  end

  def move(speed, command) do
    GenServer.call(:dotstar, {:move, 120, speed, command})
  end

  def release() do
    GenServer.call(:dotstar, :release)
    GenServer.stop(:dotstar)
  end

  @impl GenServer
  def handle_call({:red, nb}, _from, pid) do
    red_command = for _ <- 1..nb, into: <<>>, do: <<255, 0, 0, 255>>
    full_command = start_frame() <> red_command <> end_frame()

    send_command(full_command, pid)

    {:reply, :ok, pid}
  end

  @impl GenServer
  def handle_call({:off, nb}, _from, pid) do
    off_command = for _ <- 1..nb, into: <<>>, do: <<224, 0, 0, 0>>
    full_command = start_frame() <> off_command <> end_frame()

    send_command(full_command, pid)

    {:reply, :ok, pid}
  end

  @impl GenServer
  def handle_call({:custom, nb, binary}, _from, pid) do
    command = for _ <- 1..nb, into: <<>>, do: binary

    send_command(command, pid)
    {:reply, :ok, pid}
  end

  @impl GenServer
  def handle_call({:cycle_start, nb}, _from, pid) do
    cycle(nb)
    {:reply, :ok, pid}
  end

  @impl GenServer
  def handle_call({:move, nb, speed, command}, _from, pid) do
    move_(nb, speed, command)
    {:reply, :ok, pid}
  end

  @impl GenServer
  def handle_call(:release, _from, pid) do
    @spi.release(pid)
    {:reply, :ok, pid}
  end

  @impl GenServer
  def handle_info({:cycle, nb}, pid) do
    command = for _ <- 1..10, into: <<>>, do: <<231, nb * 10, nb * 10, nb * 10>>
    full_command = start_frame() <> command <> end_frame()

    send_command(full_command, pid)
    cycle(nb)
    {:noreply, pid}
  end

  @impl GenServer
  def handle_info({:moving, nb, speed, command}, pid) do
    empty = for _ <- 1..(120 - nb), into: <<>>, do: <<224, 0, 0, 0>>
    full_command = start_frame() <> empty <> command
    send_command(full_command, pid)
    move_(nb, speed, command)

    {:noreply, pid}
  end

  defp start_frame() do
    <<0, 0, 0, 0>>
  end

  defp end_frame() do
    <<255, 255, 255, 255, 255, 255, 255, 255, 255>>
  end

  defp send_command(command, pid) do
    @spi.transfer(pid, command)
  end

  defp cycle(nb) do
    if nb > 0 do
      Process.send_after(self(), {:cycle, nb - 1}, 200)
    end
  end

  def move_(nb, speed, command) do
    if nb > 0 do
      Process.send_after(self(), {:moving, nb - 1, speed, command}, speed)
    end
  end
end
