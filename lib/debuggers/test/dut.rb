module Debuggers
  module Test
    # A simple DUT model used to test the debuggers
    class DUT

      include JTAG
      include JTAG2IPS
      include RGen::Pins
      include RGen::Registers

      def initialize
        add_pin :tclk
        add_pin :tdi
        add_pin :tdo
        add_pin :tms

        reg :reg32, 0x20 do
          bits 31..0, :data
        end
      end

      # Hook the JTAG2IPS into the register API, any register read
      # requests will use the JTAG2IPS by default
      def read_register(reg, options={})
        jtag2ips.read_register(reg, options)
      end

      # As above for write requests
      def write_register(reg, options={})
        jtag2ips.write_register(reg, options)
      end

    end
  end
end
