Pattern.create do
  ss 'Verify different shift_ir lengths'

  $dut.jtag.write_ir(0x7)

  $dut.jtag.write_ir(0x8, size: 5)

  $dut.jtag.write_ir(0x9, size: 6)
end
