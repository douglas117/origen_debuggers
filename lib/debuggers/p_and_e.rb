module Debuggers
  # Driver for the P&E Microsystems debugger: http://www.pemicro.com
  #
  # For reference here is a command list for this debugger. Note, many commands can be
  # altered using additional opperands, see help for details.  Note that while
  # not recommended any of these can be called directly from an application by using the
  # dw (direct write) method, e.g.
  #
  #   $tester.dw "****"
  #   $tester.dw "****"
  #
  # Available commands are:
  #
  # write_ir  write "raw" jtag to the instruction register
  # write_dr  write "raw" jtag to the data register
  #
  # ADDSPR 	Sets user-defined SPR name to equal user-defined SPR number.
  # ASCIIF3 (ASCIIF6) 	Toggle the F3(F6) memory window between showing hexadecimal bytes and ASCII characters.  Nonprintable characters are shown as an ASCII period ('.').
  # ASM 	Assemble instructions.
  # BELL 	Sound Bell
  # BF  	Block fill memory.
  # BGND_TIME 	Starts processor execution at the current Program Counter and logs time since the last BGND instruction each time a BGND instruction is encountered.
  # BR  	Set instruction breakpoint.
  # CAPTURE 	Open a capture file named 'filename'.
  # CAPTUREOFF 	Turn off capturing and close the current capture file.
  # CLEARMAP	Remove all symbolic mapfile names. 
  # CLEARSYMBOL	Remove all temporary symbols. 
  # CLEARVAR 	Clears variables list from Variables window.
  # CODE 	Show disassembled code in the code window starting at address add.  If you specify an address in the middle of an intended instruction, improper results may occur.
  # COLORS 	Change Debugger Colors
  # COUNT 	Counts the number of times breakpoints in internal counter table are executed.  Allows optional stop and start parameters to be set.
  # COUNTER 	Add or subtract a location from the internal counter table.  Using this command with no address shows the current counters.
  # CR  	Set Condition Register.
  # CTR 	Set Counter Register
  # DASM 	Disassemble Instructions
  # DUMP_TRACE	Dump current trace buffer.
  # DUMP 	Dumps memory to screen.
  # EVAL	Evaluate expression.
  # EXECUTE_OPCODE Treats numeric parameter as an opcode and executes it.
  # EXIT	Exit debugger.
  # FPSCR 	Set Floating Point Status And Control Register
  # FR(x) 	Set Floating Point Register.
  # G or GO  	Begin program execution.
  # GOALL  	Begin program execution for multi-core devices..
  # GOEXIT 	Begin program execution without breakpoints and terminate debugger software.
  # GOTIL 	Execute until address.
  # GOTILROM 	Execute fast single steps without updating the screen, until the address is reached.  This is the fastest way to breakpoint in ROM.
  # HELP	Bring up the help window.
  # HGO 	Begin Program Execution
  # HGOALL 	Begin Program Execution For Multi-Core Devices
  # HLOAD 	Load ELF/DWARF/S19/MAP Object And Debug Information
  # HLOADMAP 	Load DWARF/MAP Debug Info Only
  # HSTEP 	High-Level Language Source Step
  # HSTEPALL 	High-Level Language Source Step For Multi-Core Devices
  # HSTEPFOR 	High-Level Language Step Forever
  # LOADDESK 	Loads the visual layout for the debugger from the last instance it was saved, such as with the SAVEDESK command.
  # LOAD_BIN 	Load a binary file of byte.  The default filename extension is .BIN.
  # LOADV_BIN 	Perform LOAD_BIN command, verify using the same file.
  # LOGFILE 	Open/Close Log File
  # LR    	Set Link Register
  # MACRO	Execute a Batch File
  # MACROEND	Stop Saving Commands to File
  # MACROSTART	Save Debug Commands to File
  # MACS 	Bring up a window with a list of macros.  These are files with the extension .ICD (such as the STARTUP.ICD macro).  Use the arrow keys and the <ENTER> key or cancel with the <ESC> key.
  # MD	        Set Memory Window 1 to a specific address.
  # MD2 	Set Memory Window 2 to a specific address.
  # MM	        Memory modify.
  # MSR 	Set Machine Status Register
  # NOBR 	Clear all break points.
  # PC	        Set Program Counter.
  # QUIET	Turn off (on) refresh of memory based windows.  
  # QUIT	Exit debugger.
  # R	        Display and edit registers (requires REG software).
  # R(x)	Set General Purpose Register R(x).
  # REM	        Place comment in macro file.
  # RESET	Force reset of device into background mode.
  # RTVAR 	Displays a specified address and its contents in the Variables window for viewing during code execution and while the part is running (real time).
  # SAVEDESK 	Saves the current visual layout of the debugger.
  # SERIAL	Set up parameters for dumb terminal. 
  # SERIALOFF	Disable the status window as a dumb terminal.
  # SERIALON	Enable the status window as a dumb terminal.
  # SHOWCODE 	Display Code at Address
  # SHOWMMU 	Displays MMU Information
  # SHOWPC 	Display Code at PC
  # SHOWSPR 	Displays SPR Information
  # SHOWTRACE 	Allows the user to view this trace buffer after having executed the TRACE command.
  # SNAPSHOT	Send snapshot of screen to capture file. 
  # SOURCEPATH 	Search for source code. 
  # SPR 	Display/modify the value of the special purpose register at address add.
  # SS	        Execute source step(s)..
  # ST 	        Execute single step in assembly.
  # STATUS 	Show registers.
  # STEP 	Same as ST.
  # STEPALL 	Execute single step in assembly for multi-core devices.
  # STEPFOR	Step forever on assembly level.
  # STEPTIL 	Step until address on the assembly level.
  # SYMBOL 	Add user symbol.
  # TIME 	Displays real time elapsed during execution of code
  # _TR 	Add register field description to the VAR Window
  # TRACE 	Monitors execution of the CPU and logs instructions.
  # UPLOAD_SREC Uloads S records to screen.
  # VAR	        Display variable.
  # VERIFY	Compare the contents of program memory with an S-record file.
  # VERSION 	Display the version number of the ICD software.
  # WATCHDOG	Disable the watchdog if active.
  # WHEREIS	Display symbol value.
  # XER 	Set Integer Exception Register.
  # ----------------------
  
  class PEmicro < Base

    def initialize
      super
      set_timeset("default", 1_000_000)
      @pat_extension = "mac"
      @comment_char = ";"
      @in_jtag = false
    end

    # All debuggers should try and support these methods
    module Common_API

      def delay(cycles)
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "delay #{cycles_to_ms(cycles)}"
      end

      def write(reg_or_val, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        self.send("write#{extract_size(reg_or_val, options)}".to_sym, reg_or_val, options)
      end
      alias :write_register :write

      def read(reg_or_val, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        self.send("read#{extract_size(reg_or_val, options)}".to_sym, reg_or_val, options)
      end
      alias :read_register :read

      # Read 8 bits of data to the given byte address
      def read8(data, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "DUMP.B #{(extract_address(data, options))} #{(extract_address(data, options))}"
      end
      alias :read_byte :read8
      alias :read_8 :read8

      # Read 16 bits of data to the given byte address
      def read16(data, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "DUMP.W #{extract_address(data, options)} #{(extract_address(data, options))}"
      end
      alias :read_word :read16
      alias :read_16 :read16

      # Read 32 bits of data to the given byte address
      def read32(data, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "DUMP.L #{(extract_address(data, options))} #{(extract_address(data, options))}"
      end
      alias :read_longword :read32
      alias :read_32 :read32

      # Write 8 bits of data to the given byte address
      def write8(data, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "MM.B #{extract_address(data, options).to_s(16).upcase} #{extract_data(data, options).to_s(16).upcase}"
      end
      alias :write_byte :write8
      alias :write_8 :write8

      # Write 16 bits of data to the given byte address
      def write16(data, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "MM.W #{extract_address(data, options).to_s(16).upcase} #{extract_data(data, options).to_s(16).upcase}"
      end
      alias :write_word :write16
      alias :write_16 :write16

      # Write 32 bits of data to the given byte address
      def write32(data, options={})
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "MM.L #{extract_address(data, options).to_s(16).upcase} #{extract_data(data, options).to_s(16).upcase}"
      end
      alias :write_longword :write32
      alias :write_32 :write32

      # @api private
      def extract_size(reg_or_val, options={})
        size = options[:size] if options[:size]
        unless size
          if reg_or_val.respond_to?(:contains_bits?) && reg_or_val.contains_bits?
            size = reg_or_val.size 
          end
        end
        raise "You must supply an :size option if not providing a register!" unless size
        unless [8,16,32].include?(size)
          raise "Only a size of 8, 16 or 32 is supported!"
        end
        size
      end

      # @api private
      def extract_data(reg_or_val, options={})
        return options[:data] if options[:data]
        return reg_or_val.data if reg_or_val.respond_to?(:data)
        reg_or_val
      end

      # @api private
      def extract_address(reg_or_val, options={})
        addr = options[:addr] || options[:address]
        return addr if addr
        addr = reg_or_val.address if reg_or_val.respond_to?(:address)
        raise "You must supply an :address option if not providing a register!" unless addr
        addr
      end

    end
    include Common_API

    # If the debugger supports JTAG definitely add these methods, this provides
    # instant compatibility with any application that uses a JTAG based protocol
    module JTAG_API
    
      # Write the given value, register or bit collection to the data register
      def write_dr(reg_or_val, options={})
        dw "jtag_start" unless @in_jtag
        @in_jtag=true
        if reg_or_val.respond_to?(:data)
          data = reg_or_val.data
          size = options[:size] || reg_or_val.size
        else
          data = reg_or_val
          size = options[:size]
        end
        dw "jtag_dr #{size}t #{data.to_s(16).downcase}"
      end

      # Read the given value, register or bit collection from the data register
      def read_dr(reg_or_val, options={})
        # Can't read the DR
      end

      # Write the given value, register or bit collection to the instruction register
      def write_ir(reg_or_val, options={})
        dw "jtag_start" unless @in_jtag
        @in_jtag=true
		size = options[:size] || 4 #Used to be hardcoded to 4 with no override capability
        if reg_or_val.respond_to?(:data)
          data = reg_or_val.data
        else
          data = reg_or_val
        end
        dw "jtag_ir #{size}t #{data.to_s(16).downcase}"
      end

      # Read the given value, register or bit collection from the instruction register
      def read_ir(reg_or_val, options={})
        # Can't read the IR
      end

    end
    include JTAG_API

    # Other methods can expose unique features of a given debugger
    module Custom

      def setPC(address)
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "PC $#{address.to_s(16).upcase}"
      end
      
      def go()
        dw "jtag_end" if @in_jtag
        @in_jtag=false
        dw "GO"
      end
      
      def halt()
        dw "\n"
      end
      
      def exit_jtag() #not expected to be typically used, should be automatically handled in code, unless manually doing  dw "..." calls
        dw "jtag_end"
        @in_jtag = false
      end
      
      def enter_jtag() #not expected to be typically used, should be automatically handled in code, unless manually doing  dw "..." calls
        dw "jtag_start"
        @in_jtag = true
      end

    end
    include Custom

    def footer_template() #if at the end of the file, and still in a jtag mode, close the jtag mode.
      if @in_jtag
        "#{RGen.root!}/lib/debuggers/p_e/jtag_end.txt"
      else
        "#{RGen.root!}/lib/debuggers/p_e/none.txt"
      end
    end

  end
end
