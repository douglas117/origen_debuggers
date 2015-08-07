$dut = Debuggers::Test::DUT.new             # Instantiate an SoC instance
$tester = Debuggers::JLink.new
RGen.mode = :debug
