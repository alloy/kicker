require File.expand_path('../test_helper', __FILE__)

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
    Rucola::FSEvents.stubs(:start_watching)
  end
  
  it "should show the usage banner when path and command are nil and exit" do
    @kicker.instance_variable_set("@path", nil)
    @kicker.command = nil
    @kicker.stubs(:validate_path_exists!)
    
    @kicker.expects(:puts).with("Usage: #{$0} [PATH] [COMMAND]")
    @kicker.expects(:exit)
    
    @kicker.start
  end
  
  it "should warn the user if the given path doesn't exist and exit" do
    @kicker.expects(:puts).with("The given path `#{@kicker.path}' does not exist.")
    @kicker.expects(:exit).with(1)
    
    @kicker.start
  end
  
  it "should start a FSEvents stream with a block which calls #process with the events" do
    @kicker.stubs(:validate_options!)
    
    Rucola::FSEvents.expects(:start_watching).with(@kicker.path).yields(['event'])
    @kicker.expects(:process).with(['event'])
    
    @kicker.start
  end
end

describe "Kicker, when running" do
  it "should execute the command if a change occured in the watched directory" do
    File.stubs(:directory?).returns(true)
    kicker = Kicker.new(:path => '/some/dir', :command => 'ls -l')
    event = mock('Rucola::FSEvents::Event')
    
    kicker.expects(:`).with(kicker.command)
    kicker.process([event])
  end
  
  it "should execute the command if a change occured to the watched file" do
    File.stubs(:directory?).returns(false)
    kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
    event = mock('Rucola::FSEvents::Event', :last_modified_file => '/some/file.rb')
    
    kicker.expects(:`).with(kicker.command)
    kicker.process([event])
  end
  
  it "should _not_ execute the command if a change occured to another file than the one being watched" do
    File.stubs(:directory?).returns(false)
    kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
    event = mock('Rucola::FSEvents::Event', :last_modified_file => '/some/other_file.rb')
    
    kicker.expects(:`).never
    kicker.process([event])
  end
end