# This file should be used to extend the origen command line tool with tasks 
# specific to your application.
#
# Also see the official docs on adding commands:
#   http://origen-sdk.org/origen/guides/custom/commands/

# Map any command aliases here, for example to allow origen -x to refer to a 
# command called execute you would add a reference as shown below: 
aliases ={
#  "-x" => "execute",
}

# The requested command is passed in here as @command, this checks it against
# the above alias table and should not be removed.
@command = aliases[@command] || @command

# Now branch to the specific task code
case @command

## Run the unit tests  
#when "specs"
#  require "rspec"
#  exit RSpec::Core::Runner.run(['spec'])

# Run the example-based (diff) tests
when "examples"  
  Origen.load_application
  status = 0

  # Compiler tests
  #ARGV = %w(templates/example.txt.erb -t debug -r approved)
  #load "origen/commands/compile.rb"
  # Pattern generator tests
  ARGV = %w(regression.list -t jlink -r approved)
  load "#{Origen.top}/lib/origen/commands/generate.rb"

  ARGV = %w(pe_regression.list -t pe -r approved)
  load "#{Origen.top}/lib/origen/commands/generate.rb"

  if Origen.app.stats.changed_files == 0 &&
     Origen.app.stats.new_files == 0 &&
     Origen.app.stats.changed_patterns == 0 &&
     Origen.app.stats.new_patterns == 0

    Origen.app.stats.report_pass
  else
    Origen.app.stats.report_fail
    status = 1
  end
  puts
  exit status  # Exit with a 1 on the event of a failure per std unix result codes

# Always leave an else clause to allow control to fall back through to the
# Origen command handler.
# You probably want to also add the command details to the help shown via
# origen -h, you can do this be assigning the required text to @application_commands
# before handing control back to Origen. Un-comment the example below to get started.
else
  @application_commands = <<-EOT
 examples     Run the examples (tests), -c will enable coverage
  EOT

end 
