require File.expand_path('../test_helper', __FILE__)

describe "Kicker, when a change occurs" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    Kicker.any_instance.stubs(:log)
    @kicker = Kicker.new(:paths => %w{ /some/file.rb /some/dir }, :command => 'ls -l')
  end
  
  it "should execute the command if a change occured to a watched path which is a file" do
    event = stub('Event', :last_modified_file => '/some/file.rb')
    
    @kicker.expects(:`).with(@kicker.command).returns('')
    @kicker.send(:process, [event])
  end
  
  it "should execute the command if a change occured to some file in watched path which is a directory" do
    event = stub('Event', :last_modified_file => '/some/dir/with/file.rb')
    
    @kicker.expects(:`).with(@kicker.command).returns('')
    @kicker.send(:process, [event])
  end
  
  it "should _not_ execute the command if a change occured to a file that isn't being watched" do
    event1 = stub('Event', :last_modified_file => '/some/other_file.rb')
    event2 = stub('Event', :last_modified_file => '/some/not/watched/dir/with/file.rb')
    
    @kicker.expects(:`).never
    @kicker.send(:process, [event1, event2])
  end
end
