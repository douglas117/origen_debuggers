module OrigenDebuggers
  # Driver for the Segger J-Link debugger: http://www.segger.com/debug-probes.html
  #
  # For reference here is the complete command list for this debugger. Note that while
  # not recommended any of these can be called directly from an application by using the
  # dw (direct write) method, e.g.
  #
  #   $tester.dw "hwinfo"
  #   $tester.dw "mem 0x1234, 10"
  #
  # Available commands are:
  # ----------------------
  #
  #   f          Firmware info
  #   h          halt
  #   g          go
  #   Sleep      Waits the given time (in milliseconds). Syntax: Sleep <delay>
  #   s          Single step the target chip
  #   st         Show hardware status
  #   hwinfo     Show hardware info
  #   mem        Read memory. Syntax: mem  <Addr>, <NumBytes> (hex)
  #   mem8       Read  8-bit items. Syntax: mem8  <Addr>, <NumBytes> (hex)
  #   mem16      Read 16-bit items. Syntax: mem16 <Addr>, <NumItems> (hex)
  #   mem32      Read 32-bit items. Syntax: mem32 <Addr>, <NumItems> (hex)
  #   w1         Write  8-bit items. Syntax: w1 <Addr>, <Data> (hex)
  #   w2         Write 16-bit items. Syntax: w2 <Addr>, <Data> (hex)
  #   w4         Write 32-bit items. Syntax: w4 <Addr>, <Data> (hex)
  #   erase      Erase internal flash of selected device. Syntax: Erase
  #   wm         Write test words. Syntax: wm <NumWords>
  #   is         Identify length of scan chain select register
  #   ms         Measure length of scan chain. Syntax: ms <Scan chain>
  #   mr         Measure RTCK react time. Syntax: mr
  #   q          Quit
  #   qc         Close JLink connection and quit
  #   r          Reset target         (RESET)
  #   rx         Reset target         (RESET). Syntax: rx <DelayAfterReset>
  #   RSetType   Set the current reset type. Syntax: RSetType <type>
  #   Regs       Display contents of registers
  #   wreg       Write register.   Syntax: wreg <RegName>, <Value>
  #   moe        Shows mode-of-entry, meaning: Reason why CPU is halted
  #   SetBP      Set breakpoint.   Syntax: SetBP <addr> [A/T] [S/H]
  #   SetWP      Set Watchpoint. Syntax: <Addr> [R/W] [<Data> [<D-Mask>] [A-Mask]]
  #   ClrBP      Clear breakpoint. Syntax: ClrBP  <BP_Handle>
  #   ClrWP      Clear watchpoint. Syntax: ClrWP  <WP_Handle>
  #   VCatch     Write vector catch. Syntax: VCatch <Value>
  #   loadbin    Load binary file into target memory.
  #                Syntax: loadbin <filename>, <addr>
  #   savebin    Saves target memory into binary file.
  #               Syntax: savebin <filename>, <addr>, <NumBytes>
  #   verifybin  Verfies if the specified binary is already in the target memory at th
  #   e specified address.
  #                Syntax: verifybin <filename>, <addr>
  #   SetPC      Set the PC to specified value. Syntax: SetPC <Addr>
  #   le         Change to little endian mode
  #   be         Change to big endian mode
  #   log        Enables log to file.  Syntax: log <filename>
  #   unlock     Unlocks a device. Syntax: unlock <DeviceName>
  #              Type unlock without <DeviceName> to get a list
  #              of supported device names.
  #              nRESET has to be connected
  #   term       Test command to visualize printf output from the target device,
  #              using DCC (SEGGER DCC handler running on target)
  #   ReadAP     Reads a CoreSight AP register.
  #              Note: First read returns the data of the previous read.
  #              An additional read of DP reg 3 is necessary to get the data.
  #   ReadDP     Reads a CoreSight DP register.
  #              Note: For SWD data is returned immediately.
  #              For JTAG the data of the previous read is returned.
  #              An additional read of DP reg 3 is necessary to get the data.
  #   WriteAP    Writes a CoreSight AP register.
  #   WriteDP    Writes a CoreSight DP register.
  #   SWDSelect  Selects SWD as interface and outputs
  #              the JTAG -> SWD swichting sequence.
  #   SWDReadAP  Reads a CoreSight AP register via SWD.
  #              Note: First read returns the data of the previous read.
  #              An additional read of DP reg 3 is necessary to get the data.
  #   SWDReadDP  Reads a CoreSight DP register via SWD.
  #              Note: Correct data is returned immediately.
  #   SWDWriteAP Writes a CoreSight AP register via SWD.
  #   SWDWriteDP Writes a CoreSight DP register via SWD.
  #   Device     Selects a specific device J-Link shall connect to
  #              and performs a reconnect.
  #              In most cases explicit selection of the device is not necessary.
  #              Selecting a device enables the user to make use of the J-Link
  #              flash programming functionality as well as using unlimited
  #              breakpoints in flash memory.
  #              For some devices explicit device selection is mandatory in order
  #              to allow the DLL to perform special handling needed by the device.
  #   ExpDevList Exports the device names from the DLL internal
  #              device list to a text file
  #                Syntax: ExpDevList <Filename>
  #   PowerTrace Perform power trace (not supported by all models)
  #   Syntax: PowerTrace <LogFile> [<ChannelMask> <RefCountSel>]
  #   <LogFile>: File to store power trace data to
  #   <ChannelMask>: 32-bit mask to specify what channels shall be enabled
  #   <SampleFreq>: Sampling frequency in Hz (0 == max)
  #   <RefCountSel>:       0: No reference count
  #                        1: Number of bytes transmitted on SWO
  #   ---- CP15 ------------
  #   rce        Read CP15.  Syntax: rce <Op1>, <CRn>, <CRm>, <Op2>
  #   wce        Write CP15. Syntax: wce <Op1>, <CRn>, <CRm>, <Op2>, <Data>
  #   ---- ICE -------------
  #   Ice        Show state of the embedded ice macrocell (ICE breaker)
  #   ri         Read Ice reg.  Syntax: ri <RegIndex>(hex)
  #   wi         Write Ice reg. Syntax: wi <RegIndex>, <Data>(hex)
  #   ---- TRACE -----------
  #   TAddBranch TRACE - Add branch instruction to trace buffer. Paras:<Addr>,<BAddr>
  #   TAddInst   TRACE - Add (non-branch) instruction to trace buffer. Syntax: <Addr>
  #   TClear     TRACE - Clear buffer
  #   TSetSize   TRACE - Set Size of trace buffer
  #   TSetFormat TRACE - SetFormat
  #   TSR        TRACE - Show Regions (and analyze trace buffer)
  #   TStart     TRACE - Start
  #   TStop      TRACE - Stop
  #   ---- SWO -------------
  #   SWOSpeed   SWO - Show supported speeds
  #   SWOStart   SWO - Start
  #   SWOStop    SWO - Stop
  #   SWOStat    SWO - Display SWO status
  #   SWORead    SWO - Read and display SWO data
  #   SWOShow    SWO - Read and analyze SWO data
  #   SWOFlush   SWO - Flush data
  #   SWOView    SWO - View terminal data
  #   ---- PERIODIC --------
  #   PERConf    PERIODIC - Configure
  #   PERStart   PERIODIC - Start
  #   PERStop    PERIODIC - Stop
  #   PERStat    PERIODIC - Display status
  #   PERRead    PERIODIC - Read and display data
  #   PERShow    PERIODIC - Read and analyze data
  #   ---- File I/O --------
  #   fwrite     Write file to emulator
  #   fread      Read file from emulator
  #   fshow      Read and display file from emulator
  #   fdelete    Delete file on emulator
  #   fsize      Display size of file on emulator
  #   ---- Test ------------
  #   TestHaltGo   Run go/halt 1000 times
  #   TestStep     Run step 1000 times
  #   TestCSpeed   Measure CPU speed.
  #                Parameters: [<RAMAddr>]
  #   TestWSpeed   Measure download speed into target memory.
  #                Parameters:  [<Addr> [<Size>]]
  #   TestRSpeed   Measure upload speed from target memory.
  #                Parameters: [<Addr> [<Size>] [<NumBlocks>]]
  #   TestNWSpeed  Measure network download speed.
  #                Parameters: [<NumBytes> [<NumReps>]]
  #   TestNRSpeed  Measure network upload speed.
  #                Parameters: [<NumBytes> [<NumReps>]]
  #   ---- JTAG ------------
  #   Config     Set number of IR/DR bits before ARM device.
  #                Syntax: Config <IRpre>, <DRpre>
  #   speed      Set JTAG speed. Syntax: speed <freq>|auto|adaptive, e.g. speed 2000,
  #   speed a
  #   i          Read JTAG Id (Host CPU)
  #   wjc        Write JTAG command (IR). Syntax: wjc <Data>(hex)
  #   wjd        Write JTAG data (DR). Syntax: wjd <Data64>(hex), <NumBits>(dec)
  #   RTAP       Reset TAP Controller using state machine (111110)
  #   wjraw      Write Raw JTAG data. Syntax: wjraw <NumBits(dec)>, <tms>, <tdi>
  #   rt         Reset TAP Controller (nTRST)
  #   ---- JTAG-Hardware ---
  #   c00        Create clock with TDI = TMS = 0
  #   c          Clock
  #   tck0       Clear TCK
  #   tck1       Set   TCK
  #   0          Clear TDI
  #   1          Set   TDI
  #   t0         Clear TMS
  #   t1         Set   TMS
  #   trst0      Clear TRST
  #   trst1      Set   TRST
  #   r0         Clear RESET
  #   r1         Set   RESET
  #   ---- Connection ------
  #   usb        Connect to J-Link via USB.  Syntax: usb <port>, where port is 0..3
  #   ip         Connect to J-Link ARM Pro or J-Link TCP/IP Server via TCP/IP.
  #              Syntax: ip <ip_addr>
  #   ---- Configuration ---
  #   si         Select target interface. Syntax: si <Interface>,
  #              where 0=JTAG and 1=SWD.
  #   power      Switch power supply for target. Syntax: power <State> [perm],
  #              where State is either On or Off. Example: power on perm
  #   wconf      Write configuration byte. Syntax: wconf <offset>, <data>
  #   rconf      Read configuration bytes. Syntax: rconf
  #   ipaddr     Show/Assign IP address and subnetmask of/to the connected J-Link.
  #   gwaddr     Show/Assign network gateway address of/to the connected J-Link.
  #   dnsaddr    Show/Assign network DNS server address of/to the connected J-Link.
  #   conf       Show configuration of the connected J-Link.
  #   ecp        Enable the  J-Link control panel.
  #   calibrate  Calibrate the target current measurement.
  #   selemu     Select a emulator to communicate with,
  #              from a list of all emulators which are connected to the host
  #              The interfaces to search on, can be specified
  #                Syntax: selemu [<Interface0> <Interface1> ...]
  #   ShowEmuList Shows a list of all emulators which are connected to the host.
  #               The interfaces to search on, can be specified.
  #                Syntax: ShowEmuList [<Interface0> <Interface1> ...]
  #
  # ----------------------
  # NOTE: Specifying a filename in command line
  # will start J-Link Commander in script mode.
  class JLink < Base
    def initialize
      super
      # The minimum time unit is 1ms
      set_timeset('default', 1_000_000)
      @pat_extension = 'jlk'
      @comment_char = '//'
    end

    # All debuggers should try and support these methods
    module Common_API
      def delay(cycles)
        dw "Sleep #{cycles_to_ms(cycles)}"
      end

      def write(reg_or_val, options = {})
        send("write#{extract_size(reg_or_val, options)}".to_sym, reg_or_val, options)
      end
      alias_method :write_register, :write

      def read(reg_or_val, options = {})
        send("read#{extract_size(reg_or_val, options)}".to_sym, reg_or_val, options)
      end
      alias_method :read_register, :read

      # Read 8 bits of data to the given byte address
      def read8(data, options = {})
        read_memory(extract_address(data, options), number_of_bytes: 1)
      end
      alias_method :read_byte, :read8
      alias_method :read_8, :read8

      # Read 16 bits of data to the given byte address
      def read16(data, options = {})
        read_memory(extract_address(data, options), number_of_bytes: 2)
      end
      alias_method :read_word, :read16
      alias_method :read_16, :read16

      # Read 32 bits of data to the given byte address
      def read32(data, options = {})
        read_memory(extract_address(data, options), number_of_bytes: 4)
      end
      alias_method :read_longword, :read32
      alias_method :read_32, :read32

      # Read 32-bit chunks of data using given byte address
      def read32data(data, options = {})
        read_memory(extract_address(data, options), type: :_32, number: options[:number])
      end

      # Write 8 bits of data to the given byte address
      def write8(data, options = {})
        dw "w1 0x#{extract_address(data, options).to_s(16).upcase}, 0x#{extract_data(data, options).to_s(16).upcase}"
      end
      alias_method :write_byte, :write8
      alias_method :write_8, :write8

      # Write 16 bits of data to the given byte address
      def write16(data, options = {})
        dw "w2 0x#{extract_address(data, options).to_s(16).upcase}, 0x#{extract_data(data, options).to_s(16).upcase}"
      end
      alias_method :write_word, :write16
      alias_method :write_16, :write16

      # Write 32 bits of data to the given byte address
      def write32(data, options = {})
        dw "w4 0x#{extract_address(data, options).to_s(16).upcase}, 0x#{extract_data(data, options).to_s(16).upcase}"
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
        unless [8, 16, 32].include?(size)
          fail 'Only a size of 8, 16 or 32 is supported!'
        end
        size
      end

      # @api private
      def extract_data(reg_or_val, options = {})
        return options[:data] if options[:data]
        return reg_or_val.data if reg_or_val.respond_to?(:data)
        reg_or_val
      end

      # @api private
      def extract_address(reg_or_val, options = {})
        addr = options[:addr] || options[:address]
        return addr if addr
        addr = reg_or_val.address if reg_or_val.respond_to?(:address)
        fail 'You must supply an :address option if not providing a register!' unless addr
        addr
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
        dw "wjd 0x#{data.to_s(16).upcase}, #{size}\nc"  # the extra clock cycle is needed here to opperate correctly on certain devices
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
        dw "wjc 0x#{data.to_s(16).upcase}"
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
          type:   :byte           # type of data to be read
        }.merge(options)

        # for backward compatibility
        options[:number] = options[:number_of_bytes] if options[:number_of_bytes]

        if options[:type] == :_32
          dw "mem32 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
        elsif options[:type] == :_16
          dw "mem16 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
        elsif options[:type] == :_8
          dw "mem8 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
        else
          dw "mem 0x#{address.to_s(16).upcase}, #{options[:number].to_hex}"
        end
      end
    end
    include Custom
  end
end
