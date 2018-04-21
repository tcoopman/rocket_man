defmodule Fw.Executer do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, nil, name: :executer)
  end

  def load_program(module) do
    GenServer.call(:executer, {:load, module})
  end

  def stop() do
    GenServer.call(:executer, :stop)
  end

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:load, module}, from, {timer, _, _}) do
    Process.cancel_timer(timer)
    handle_call({:load, module}, from, nil)
  end

  @impl GenServer
  def handle_call({:load, module}, _from, nil) do
    module_state = apply(module, :new, [120])
    timer = schedule_execution(0)
    {:reply, :ok, {timer, module, module_state}}
  end

  @impl GenServer
  def handle_call(:stop, _from, _) do
    Fw.Dotstar.off(120)
    {:reply, :ok, nil}
  end

  @impl GenServer
  def handle_info(:execute, {_timer, module, module_state}) do
    {command, sleep, module_state} = apply(module, :execute, [module_state])
    Fw.Dotstar.custom(1, command)
    timer = schedule_execution(sleep)

    {:noreply, {timer, module, module_state}}
  end

  @impl GenServer
  def handle_info(_, nil) do
    {:noreply, nil}
  end

  defp schedule_execution(sleep) do
    Process.send_after(self(), :execute, sleep)
  end
end
