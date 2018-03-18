use Mix.Config

config :nerves_init_gadget,
  ifname: "wlan0",
  address_method: :dhcp,
  mdns_domain: "rocket_man.local",
  node_name: nil,
  node_host: :mdns_domain

config :nerves_network, regulatory_domain: "BE"

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

config :nerves_network, :default,
  wlan0: [
    ssid: System.get_env("NERVES_NETWORK_SSID"),
    psk: System.get_env("NERVES_NETWORK_PSK"),
    key_mgmt: String.to_atom(key_mgmt)
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

config :ui, UiWeb.Endpoint,
  http: [port: 80],
  url: [host: "rocket_man.local", port: 80],
  secret_key_base: "DAIQsot2HXwL9xNGPBdjhFYyBjAS825OzUn7LBugqT1hgT/lx7M8KJ0w7ISIOSjB",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [view: UiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ui.PubSub, adapter: Phoenix.PubSub.PG2]

config :ui, :leds, Fw.Leds

config :ale, :spi, Fw.SPI.Hardware
config :ale, :gpio, Fw.GPIO.Hardware
config :fw, :button_ignore_time, 300
