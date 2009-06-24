require File.expand_path('../test_helper', __FILE__)

describe "Kicker, in general" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    @kicker = Kicker.new(:paths => %w{ /some/dir }, :command => 'ls -l')
  end
  
  it "should print a log entry with timestamp" do
    now = Time.now
    Time.stubs(:now).returns(now)
    
    @kicker.expects(:puts).with("[#{now}] the message")
    @kicker.send(:log, 'the message')
  end
  
  it "should log the output of the command indented by 2 spaces and whether or not the command succeeded" do
    @kicker.stubs(:`).returns("line 1\nline 2")
    
    @kicker.expects(:log).with('Change occured. Executing command:')
    @kicker.expects(:log).with('  line 1')
    @kicker.expects(:log).with('  line 2')
    @kicker.expects(:log).with('Command succeeded')
    @kicker.send(:execute!)
    
    @kicker.stubs(:last_command_succeeded?).returns(false)
    @kicker.stubs(:last_command_status).returns(123)
    @kicker.expects(:log).with('Change occured. Executing command:')
    @kicker.expects(:log).with('  line 1')
    @kicker.expects(:log).with('  line 2')
    @kicker.expects(:log).with('Command failed (123)')
    @kicker.send(:execute!)
  end
  
  it "should send the Growl messages with the default click callback" do
    @kicker.stubs(:log)
    
    @kicker.stubs(:`).returns("line 1\nline 2")
    @kicker.use_growl = true
    
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal').times(2)
    
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:succeeded], 'Kicker: Command succeeded', "line 1\nline 2").yields
    @kicker.send(:execute!)
    
    @kicker.stubs(:last_command_succeeded?).returns(false)
    @kicker.stubs(:last_command_status).returns(123)
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:failed], 'Kicker: Command failed (123)', "line 1\nline 2").yields
    @kicker.send(:execute!)
  end
  
  it "should send the Growl messages with a click callback which executes the specified growl command when succeeded" do
    @kicker.stubs(:log)
    
    @kicker.stubs(:`).returns("line 1\nline 2")
    @kicker.use_growl = true
    @kicker.growl_command = 'ls -l'
    
    @kicker.expects(:system).with('ls -l').times(1)
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal').times(1)
    
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:succeeded], 'Kicker: Command succeeded', "line 1\nline 2").yields
    @kicker.send(:execute!)
    
    @kicker.stubs(:last_command_succeeded?).returns(false)
    @kicker.stubs(:last_command_status).returns(123)
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:failed], 'Kicker: Command failed (123)', "line 1\nline 2").yields
    @kicker.send(:execute!)
  end
end