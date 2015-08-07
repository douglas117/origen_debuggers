module Debuggers
  # This is base class of all debuggers, any methods/attributes
  # defined here will be available to all
  class Base < RGen::Tester::CommandBasedTester

    # Returns true if the debugger supports JTAG
    def jtag?
      respond_to?(:write_dr)
    end

    # Concept of a cycle not supported, print out an error to the output
    # file to alert the user that execution has hit code that is not 
    # compatible with a command based tester.
    def cycle(*args)
      cc "*** Cycle called ***"
    end

  end
end
