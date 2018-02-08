require 'origen_testers'
module OrigenDebuggers
  # This is base class of all debuggers, any methods/attributes
  # defined here will be available to all
  class Base < OrigenTesters::CommandBasedTester
    # Testers don't listen for callbacks
    class OnCreateCaller
      include Origen::Callbacks

      def initialize(tester)
        @tester = tester
      end

      def on_create
        @tester.on_create if @tester.respond_to?(:on_create)
      end
    end

    def initialize
      OnCreateCaller.new(self)
      super
    end

    # Returns true if the debugger supports JTAG
    def jtag?
      respond_to?(:write_dr)
    end

    # Concept of a cycle not supported, print out an error to the output
    # file to alert the user that execution has hit code that is not
    # compatible with a command based tester.
    def cycle(*args)
      cc '*** Cycle called ***'
    end
  end
end
