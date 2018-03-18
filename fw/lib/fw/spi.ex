defmodule Fw.SPI do
  @type spi_option ::
          {:speed_hz, pos_integer}
          | {:delay_us, non_neg_integer}

  @callback start_link(device_name :: String.t(), options :: [spi_option]) :: {:ok, pid}

  @callback transfer(pid, command :: binary) :: binary | {:error, term}

  @callback release(pid) :: :ok
end
