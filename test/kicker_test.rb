require File.expand_path('../test_helper', __FILE__)

describe "Kicker.parse_options" do
  it "should parse the paths" do
    Kicker.parse_options(%w{ /some/file.rb })[:paths].should == %w{ /some/file.rb }
    Kicker.parse_options(%w{ /some/file.rb /a/dir /and/some/other/file.rb })[:paths].should ==
      %w{ /some/file.rb /a/dir /and/some/other/file.rb }
  end
  
  it "should parse the command" do
    Kicker.parse_options(%w{ -e ls })[:command].should == 'ls'
    Kicker.parse_options(%w{ --execute ls })[:command].should == 'ls'
  end
  
  it "should parse if growl shouldn't be used" do
    Kicker.parse_options([])[:growl].should == true
    Kicker.parse_options(%w{ --no-growl })[:growl].should == false
  end
  
  it "should parse the Growl command to use when the user clicks the Growl succeeded message" do
    Kicker.parse_options(%w{ --growl-command ls })[:growl_command].should == 'ls'
  end
end

describe "Kicker, when initializing" do
  before do
    @kicker = Kicker.new(:paths => %w{ /some/dir a/relative/path }, :command => 'ls -l')
  end
  
  it "should return the extended paths to watch" do
    @kicker.paths.should == ['/some/dir', File.expand_path('a/relative/path')]
  end
  
  it "should return the command to execute once a change occurs" do
    @kicker.command.should == 'sh -c "ls -l"'
  end
end

describe "Kicker, when starting" do
  before do
    @kicker = Kicker.new(:paths => %w{ /some/file.rb }, :command => 'ls -l')
    @kicker.stubs(:log)
    Rucola::FSEvents.stubs(:start_watching)
    OSX.stubs(:CFRunLoopRun)
  end
  
  it "should show the usage banner and exit when there are no paths and a command" do
    @kicker.instance_variable_set("@paths", [])
    @kicker.command = nil
    @kicker.stubs(:validate_paths_exist!)
    
    Kicker::OPTION_PARSER.stubs(:call).returns(mock('OptionParser', :help => 'help'))
    @kicker.expects(:puts).with("help")
    @kicker.expects(:exit)
    
    @kicker.start
  end
  
  it "should warn the user and exit if any of the given paths doesn't exist" do
    @kicker.expects(:puts).with("The given path `/some/file.rb' does not exist")
    @kicker.expects(:exit).with(1)
    
    @kicker.start
  end
  
  it "should start a FSEvents stream which watches all paths, but the dirnames of paths if they're files" do
    @kicker.stubs(:validate_options!)
    File.stubs(:directory?).with('/some/file.rb').returns(false)
    
    Rucola::FSEvents.expects(:start_watching).with('/some')
    @kicker.start
  end
  
  it "should start a FSEvents stream with a block which calls #process with any generated events" do
    @kicker.stubs(:validate_options!)
    
    Rucola::FSEvents.expects(:start_watching).yields(['event'])
    @kicker.expects(:process).with(['event'])
    
    @kicker.start
  end
  
  it "should setup a signal handler for `INT' which stops the FSEvents stream and exits" do
    @kicker.stubs(:validate_options!)
    
    watch_dog = stub('Rucola::FSEvents')
    Rucola::FSEvents.stubs(:start_watching).returns(watch_dog)
    
    @kicker.expects(:trap).with('INT').yields
    watch_dog.expects(:stop)
    @kicker.expects(:exit)
    
    @kicker.start
  end
  
  it "should start a CFRunLoop" do
    @kicker.stubs(:validate_options!)
    
    OSX.expects(:CFRunLoopRun)
    @kicker.start
  end
  
  it "should register with growl if growl should be used" do
    @kicker.stubs(:validate_options!)
    @kicker.use_growl = true
    
    Growl::Notifier.sharedInstance.expects(:register).with('Kicker', Kicker::GROWL_NOTIFICATIONS.values)
    @kicker.start
  end
  
  it "should _not_ register with growl if growl should not be used" do
    @kicker.stubs(:validate_options!)
    @kicker.use_growl = false
    
    Growl::Notifier.sharedInstance.expects(:register).never
    @kicker.start
  end
end

describe "Kicker, when a change occurs" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    Kicker.any_instance.stubs(:log)
    @kicker = Kicker.new(:paths => %w{ /some/file.rb /some/dir }, :command => 'ls -l')
  end
  
  it "should execute the command if a change occured to a watched path which is a file" do
    event = stub('Event', :last_modified_file => '/some/file.rb')
    
    @kicker.expects(:`).with(@kicker.command).returns('')
    @kicker.process([event])
  end
  
  it "should execute the command if a change occured to some file in watched path which is a directory" do
    event = stub('Event', :last_modified_file => '/some/dir/with/file.rb')
    
    @kicker.expects(:`).with(@kicker.command).returns('')
    @kicker.process([event])
  end
  
  it "should _not_ execute the command if a change occured to a file that isn't being watched" do
    event1 = stub('Event', :last_modified_file => '/some/other_file.rb')
    event2 = stub('Event', :last_modified_file => '/some/not/watched/dir/with/file.rb')
    
    @kicker.expects(:`).never
    @kicker.process([event1, event2])
  end
end

describe "Kicker, in general" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    @kicker = Kicker.new(:paths => %w{ /some/dir }, :command => 'ls -l')
  end
  
  it "should print a log entry with timestamp" do
    now = Time.now
    Time.stubs(:now).returns(now)
    
    @kicker.expects(:puts).with("[#{now}] the message")
    @kicker.log('the message')
  end
  
  it "should log the output of the command indented by 2 spaces and whether or not the command succeeded" do
    @kicker.stubs(:`).returns("line 1\nline 2")
    
    @kicker.expects(:log).with('Change occured. Executing command:')
    @kicker.expects(:log).with('  line 1')
    @kicker.expects(:log).with('  line 2')
    @kicker.expects(:log).with('Command succeeded')
    @kicker.execute!
    
    @kicker.stubs(:last_command_succeeded?).returns(false)
    @kicker.stubs(:last_command_status).returns(123)
    @kicker.expects(:log).with('Change occured. Executing command:')
    @kicker.expects(:log).with('  line 1')
    @kicker.expects(:log).with('  line 2')
    @kicker.expects(:log).with('Command failed (123)')
    @kicker.execute!
  end
  
  it "should send the Growl messages with the default click callback" do
    @kicker.stubs(:log)
    
    @kicker.stubs(:`).returns("line 1\nline 2")
    @kicker.use_growl = true
    
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal').times(2)
    
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:succeeded], 'Kicker: Command succeeded', "line 1\nline 2").yields
    @kicker.execute!
    
    @kicker.stubs(:last_command_succeeded?).returns(false)
    @kicker.stubs(:last_command_status).returns(123)
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:failed], 'Kicker: Command failed (123)', "line 1\nline 2").yields
    @kicker.execute!
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
    @kicker.execute!
    
    @kicker.stubs(:last_command_succeeded?).returns(false)
    @kicker.stubs(:last_command_status).returns(123)
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:change], 'Kicker: Change occured', 'Executing command')
    @kicker.expects(:growl).with(Kicker::GROWL_NOTIFICATIONS[:failed], 'Kicker: Command failed (123)', "line 1\nline 2").yields
    @kicker.execute!
  end
end