require File.expand_path('../test_helper', __FILE__)

describe "Kicker, concerning its utility methods" do
  before do
    Kicker.stubs(:last_command_succeeded?).returns(true)
  end
  
  it "should print a log entry with timestamp" do
    now = Time.now
    Time.stubs(:now).returns(now)
    
    Kicker.expects(:puts).with("[#{now}] the message")
    Kicker.send(:log, 'the message')
  end
  
  it "should log the output of the command indented by 2 spaces and whether or not the command succeeded" do
    Kicker.stubs(:`).returns("line 1\nline 2")
    
    Kicker.expects(:log).with('Change occured, executing command: ls')
    Kicker.expects(:log).with('  line 1')
    Kicker.expects(:log).with('  line 2')
    Kicker.expects(:log).with('Command succeeded')
    Kicker.execute_command('ls')
    
    Kicker.stubs(:last_command_succeeded?).returns(false)
    Kicker.stubs(:last_command_status).returns(123)
    Kicker.expects(:log).with('Change occured, executing command: ls')
    Kicker.expects(:log).with('  line 1')
    Kicker.expects(:log).with('  line 2')
    Kicker.expects(:log).with('Command failed (123)')
    Kicker.execute_command('ls')
  end
  
  it "should send the Growl messages with the default click callback" do
    Kicker.stubs(:log)
    
    Kicker.stubs(:`).returns("line 1\nline 2")
    Kicker.use_growl = true
    
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal').times(2)
    
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', 'ls')
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:succeeded], 'Kicker: Command succeeded', "line 1\nline 2").yields
    Kicker.execute_command('ls')
    
    Kicker.stubs(:last_command_succeeded?).returns(false)
    Kicker.stubs(:last_command_status).returns(123)
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', 'ls')
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:failed], 'Kicker: Command failed (123)', "line 1\nline 2").yields
    Kicker.execute_command('ls')
  end
  
  it "should send the Growl messages with a click callback which executes the specified growl command when succeeded" do
    Kicker.stubs(:log)
    
    Kicker.stubs(:`).returns("line 1\nline 2")
    Kicker.use_growl = true
    Kicker.growl_command = 'ls -l'
    
    Kicker.expects(:system).with('ls -l').times(1)
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal').times(1)
    
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', 'ls')
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:succeeded], 'Kicker: Command succeeded', "line 1\nline 2").yields
    Kicker.execute_command('ls')
    
    Kicker.stubs(:last_command_succeeded?).returns(false)
    Kicker.stubs(:last_command_status).returns(123)
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured, executing command:', 'ls')
    Kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:failed], 'Kicker: Command failed (123)', "line 1\nline 2").yields
    Kicker.execute_command('ls')
  end
end

describe "A Kicker instance, concerning its utility methods" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    @kicker = Kicker.new(:paths => %w{ /some/dir }, :command => 'ls -l')
  end
  
  it "should forward log calls to the Kicker class" do
    Kicker.expects(:log).with('the message')
    @kicker.send(:log, 'the message')
  end
  
  it "should forward execute_command calls to the Kicker class" do
    Kicker.expects(:execute_command).with('ls')
    @kicker.send(:execute_command, 'ls')
  end
end