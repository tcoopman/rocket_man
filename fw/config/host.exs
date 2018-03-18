use Mix.Config

defmodule Fw.SpiDev do
end

config :spi, :module, Fw.SpiDev

config :ui, UiWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []