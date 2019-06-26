Pattern.create do
  ss "Verify the time base, wait for 10ms which should be 10 sleep cycles"
  $tester.wait :time_in_ms => 10
  load "#{Origen.root}/pattern/_workout.rb"
end
