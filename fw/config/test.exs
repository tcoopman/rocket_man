use Mix.Config

config :ale, :spi, Fw.SPI.Mock
config :ale, :gpio, Fw.GPIO.Mock

config :fw, :button_ignore_time, 20
