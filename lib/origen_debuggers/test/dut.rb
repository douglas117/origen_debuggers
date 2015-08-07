module OrigenDebuggers
  module Test
    # A simple DUT model used to test the debuggers
    class DUT
      include OrigenJTAG
      include Origen::Pins
      include Origen::Registers

      def initialize
        add_pin :tclk
        add_pin :tdi
        add_pin :tdo
        add_pin :tms

        reg :reg32, 0x20 do
          bits 31..0, :data
        end
      end

      # Hook the Nexus into the register API, any register read
      # requests will use the Nexus by default
      def read_register(reg, options = {})
        # nexus.read_register(reg, options)
        cc 'Needs to be enabled when a register protocol is available'
      end

      # As above for write requests
      def write_register(reg, options = {})
        # nexus.write_register(reg, options)
        cc 'Needs to be enabled when a register protocol is available'
      end
    end
  end
end
