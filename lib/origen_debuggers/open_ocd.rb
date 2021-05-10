module OrigenDebuggers
  
  class OpenOCD < OrigenTesters::CommandBasedTester
    def on_create
      # The minimum time unit is 1ms
      set_timeset('default', 1_000_000)
      @pat_extension = 'tcl'
      @comment_char = '   # '
    end

    # All debuggers should try and support these methods
    module Common_API
      def delay(cycles) # Done
        dw "sleep #{cycles_to_ms(cycles)}"
      end

      def write(reg_or_val, options = {})
        if reg_or_val.respond_to?(:data)
          debugger
          cc("[OpenOCD] Write #{reg_or_val.name.upcase} register, address: 0x%06X with value: 0x%08X" % [reg_or_val.address, reg_or_val.data])
        end
        write_dr(reg_or_val, options)
      end
      alias_method :write_register, :write

      def read(reg_or_val, options = {})
        if reg_or_val.respond_to?(:data)
          cc("[JLink] Read #{reg_or_val.name.upcase} register, address: 0x%06X, expect value: 0x%08X" % [reg_or_val.address, reg_or_val.data])
        end
        send("read#{extract_size(reg_or_val, options)}".to_sym, reg_or_val, options)
      end
      alias_method :read_register, :read

      # Read 8 bits of data to the given byte address
      def read8(data, options = {})
        #read_memory(extract_address(data, options), number: 1)
      end
      alias_method :read_byte, :read8
      alias_method :read_8, :read8

      # Read 16 bits of data to the given byte address
      def read16(data, options = {})
        #read_memory(extract_address(data, options), number: 2)
      end
      alias_method :read_word, :read16
      alias_method :read_16, :read16

      # Read 32 bits of data to the given byte address
      #
      # data can be array of registers, if array of data then will auto-incrememnt address
      def read32(data, options = {})
        options = { optimize: false,   # whether to use a single command to do the read
                    # user may care regarding endianness
                    size:     32,        # size of each item in bits
                    number:   1,        # default number of items
        }.merge(options)
        #options[:optimize] = options[:optimized] if options[:optimized]

        #if data.is_a?(Array)
         # if options[:optimize]
            # for optimized option assume single starting address for data in array
          #  read_memory(extract_address(data, options), size: options[:size], number: data.length)
          #else
          #  data.each_index do |i|
          #    data_item = data[i]
              # do separate writes for each 32-bit word
          #    read_memory(extract_address(data_item, options) + i * (options[:size] / 8), size: options[:size])
          #  end
         # end
        #else
          #if options[:optimize]
           # read_memory(extract_address(data, options), size: options[:size], number: options[:number])
          #else
          #  read_memory(extract_address(data, options), number: (options[:size] / 8))
          #end
        #end
      end
      alias_method :read_longword, :read32
      alias_method :read_32, :read32

      # Write 8 bits of data to the given byte address
      def write8(data, options = {})
        #dw "w1 0x#{extract_address(data, options).to_s(16).upcase}, 0x#{extract_data(data, options).to_s(16).upcase}"
      end
      alias_method :write_byte, :write8
      alias_method :write_8, :write8

      # Write 16 bits of data to the given byte address
      def write16(data, options = {})
        #dw "w2 0x#{extract_address(data, options).to_s(16).upcase}, 0x#{extract_data(data, options).to_s(16).upcase}"
      end
      alias_method :write_word, :write16
      alias_method :write_16, :write16

      # Write 32 bits of data to the given byte address
      def write32(data, options = {})
        #dw "w4 0x#{extract_address(data, options).to_s(16).upcase}, 0x#{extract_data(data, options).to_s(16).upcase}"
      end
      alias_method :write_longword, :write32
      alias_method :write_32, :write32

      # @api private
      def extract_size(reg_or_val, options = {})
        size = options[:size] if options[:size]
        unless size
          if reg_or_val.respond_to?(:contains_bits?) && reg_or_val.contains_bits?
            size = reg_or_val.size
          end
        end
        fail 'You must supply an :size option if not providing a register!' unless size
        size
      end

      # @api private
      def extract_data(reg_or_val, options = {})
        #return options[:data] if options[:data]
        #return reg_or_val.data if reg_or_val.respond_to?(:data)
        #reg_or_val
      end

      # @api private
      def extract_address(reg_or_val, options = {})
        #addr = options[:addr] || options[:address]
        #return addr if addr
        #addr = reg_or_val.address if reg_or_val.respond_to?(:address)
        #fail 'You must supply an :address option if not providing a register!' unless addr
        #addr
      end
    end
    include Common_API

    # If the debugger supports JTAG definitely add these methods, this provides
    # instant compatibility with any application that uses a JTAG based protocol
    module JTAG_API
      # Write the given value, register or bit collection to the data register
      def write_dr(reg_or_val, options = {})
        if reg_or_val.respond_to?(:data)
          data = reg_or_val.data
          size = options[:size] || reg_or_val.size
        else
          data = reg_or_val
          size = options[:size]
        end
        dw "drscan tsmc_tap_controller.cpu #{size} 0x#{data.to_s(16).upcase}\n"  # the extra clock cycle is needed here to opperate correctly on certain devices
        # the added clock cycle means that the JLink opperation matches the atp tester opperation (J750 etc)
        # some devices may function without the addition, however an extra clock cycle in "run-Test/idle" is unlikely to
        # break anything so has been added universally.
      end

      # Read the given value, register or bit collection from the data register
      def read_dr(reg_or_val, options = {})
        # Can't read the DR via J-Link
      end

      # Write the given value, register or bit collection to the instruction register
      def write_ir(reg_or_val, options = {})
        if reg_or_val.respond_to?(:data)
          data = reg_or_val.data
        else
          data = reg_or_val
        end
        dw "irscan tsmc_tap_controller.cpu 0x#{data.to_s(16).upcase}"
      end

      # Read the given value, register or bit collection from the instruction register
      def read_ir(reg_or_val, options = {})
        # Can't read the IR via J-Link
      end
    end
    include JTAG_API

    # Other methods can expose unique features of a given debugger
    module Custom
      def set_interface(interface)
        # set interface and reset
        value = interface == :swd ? 1 : 0   # set interface : JTAG=0, SWD=1
        dw "si #{value}"
        # pull a reset now
        dw 'RSetType 2' # reset via reset pin which should be same as manual reset pin
        # toggle.  Also forces CPU to halt when it comes out of reset
        dw 'r'          # reset and halts the device (prob not needed)
        dw 'halt'       # halt core just in case
      end

      def halt
        dw 'halt'
      end

      def quit
        dw 'q'
      end

      def read_memory(address, options = {})
        options = {
          number: 1,    # number of items to read
          size:   8     # number of bits in each item
        }.merge(options)

        if options[:size] == 32
          dw "mem32 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
        elsif options[:size] == 16
          dw "mem16 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
        elsif options[:size] == 8
          dw "mem 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
          # not sure difference between mem and mem8
        else
          fail 'You must supply a valid :size option!'
        end
      end
    end
    include Custom
  end
end
