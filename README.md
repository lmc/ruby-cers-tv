# RubyCersTv

Ruby cers API for Sony TVs
© Luke Mcildoon 2012 - MIT licenced

Some ethernet/wifi-enabled Sony TVs have a webserver running on them for remote control from mobile devices. This is a super-simple work-in-progress interface into everything it exposes.

In typical Sony fashion, there's a security system in place that the device has to "pair" with the TV before it can issue commands. However, if you know the MAC address of a paired device, the TV doesn't actually check that the command came from that MAC address, only checking a HTTP header sent in the request.


## Usage

```ruby
tv_ip = "192.168.0.37"
fake_mac = "c0-01-fa-ce-d0-0d"

device = RubyCersTv::Device.new(tv_ip,fake_mac)

# send pairing request (will need to accept using the TV remote)
device.register(fake_mac)

# get encoded IR commands
device.get_remote_command_list
# => [{"name"=>"Confirm", "value"=>"AAAAAQAAAAEAAABlAw==", "type"=>"ircc"}, ... ]

# send encoded IR commands
device.send_ircc("AAAAAQAAAAEAAABlAw==")

# TODO: handle 'url' commands
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

