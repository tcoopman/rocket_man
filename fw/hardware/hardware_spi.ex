defmodule Fw.HardwareSPI do
  @behaviour Fw.SPI

  alias ElixirAle.SPI

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