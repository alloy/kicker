require File.expand_path('../test_helper', __FILE__)

describe "Kicker.parse_options" do
  it "should parse the path" do
    Kicker.parse_options(['/some/file.rb'])[:path].should == '/some/file.rb'
  end
  
  it "should parse the command" do
    Kicker.parse_options(%w{ -e ls })[:command].should == 'ls'
    Kicker.parse_options(%w{ --execute ls })[:command].should == 'ls'
  end
  
  it "should parse if growl shouldn't be used" do
    Kicker.parse_options([])[:growl].should == true
    Kicker.parse_options(%w{ --no-growl })[:growl].should == false
  end
  
  it "should parse the Growl message to use when the command succeeded" do
    Kicker.parse_options(%w{ --growl-message Done! })[:growl_message].should == 'Done!'
  end
  
  it "should parse the Growl command to use when the user clicks the Growl succeeded message" do
    Kicker.parse_options(%w{ --growl-command ls })[:growl_command].should == 'ls'
  end
end

describe "Kicker, when initializing" do
  before do
    @kicker = Kicker.new(:path => '/some/dir', :command => 'ls -l')
  end
  
  it "should return the path to watch" do
    File.stubs(:directory?).with('/some/dir').returns(true)
    Kicker.new(:path => '/some/dir').path.should == '/some/dir'
  end
  
  it "should return the command to execute once a change occurs" do
    Kicker.new(:command => 'ls -l').command.should == 'sh -c "ls -l"'
  end
  
  it "should return the dirname of the path if the given path is a file" do
    File.stubs(:directory?).with('/some/file.rb').returns(false)
    Kicker.new(:path => '/some/file.rb').path.should == '/some'
  end
  
  it "should return the path to the file if the given path is a file" do
    @kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
    @kicker.file.should == '/some/file.rb'
  end
end

describe "Kicker, when starting" do
  before do
    @kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
    @kicker.stubs(:log)
    Rucola::FSEvents.stubs(:start_watching)
    OSX.stubs(:CFRunLoopRun)
  end
  
  it "should show the usage banner when path and command are nil and exit" do
    @kicker.instance_variable_set("@path", nil)
    @kicker.command = nil
    @kicker.stubs(:validate_path_exists!)
    
    Kicker::OPTION_PARSER.stubs(:call).returns(mock('OptionParser', :help => 'help'))
    @kicker.expects(:puts).with("help")
    @kicker.expects(:exit)
    
    @kicker.start
  end
  
  it "should warn the user if the given path doesn't exist and exit" do
    @kicker.expects(:puts).with("The given path `#{@kicker.path}' does not exist")
    @kicker.expects(:exit).with(1)
    
    @kicker.start
  end
  
  it "should start a FSEvents stream with a block which calls #process with the events" do
    @kicker.stubs(:validate_options!)
    
    Rucola::FSEvents.expects(:start_watching).with(@kicker.path).yields(['event'])
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
end

describe "Kicker, when a change occurs" do
  before do
    File.stubs(:directory?).returns(false)
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    Kicker.any_instance.stubs(:log)
    @kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
  end
  
  it "should execute the command if a change occured to the watched file" do
    event = mock('Rucola::FSEvents::Event', :last_modified_file => '/some/file.rb')
    
    @kicker.expects(:`).with(@kicker.command).returns('')
    @kicker.process([event])
  end
  
  it "should _not_ execute the command if a change occured to another file than the one being watched" do
    event = mock('Rucola::FSEvents::Event', :last_modified_file => '/some/other_file.rb')
    
    @kicker.expects(:`).never
    @kicker.process([event])
  end
  
  it "should execute the command if a change occured in the watched directory" do
    File.stubs(:directory?).returns(true)
    kicker = Kicker.new(:path => '/some/dir', :command => 'ls -l')
    event = mock('Rucola::FSEvents::Event')
    
    kicker.expects(:`).with(kicker.command).returns('')
    kicker.process([event])
  end
end

describe "Kicker, in general" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    @kicker = Kicker.new(:path => '/some/dir', :command => 'ls -l')
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
end