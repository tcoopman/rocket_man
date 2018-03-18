defmodule Fw.SPI.Hardware do
  @behaviour Fw.SPI

  alias ElixirALE.SPI

  def start_link(device_name, options) do
    SPI.start_link(device_name, options)
  end

  def transfer(pid, command) do
    case SPI.transfer(pid, command) do
      {:error, term} -> {:error, term}
      _ -> :ok
    end
  end

  def release(pid), do: SPI.release(pid)
end
