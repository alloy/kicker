require File.expand_path('../test_helper', __FILE__)

describe "Kicker, when initializing" do
  before do
    @kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
  end
  
  it "should return the path to watch" do
    @kicker.path.should == '/some/file.rb'
  end
  
  it "should return the command to execute once a change occurs" do
    @kicker.command.should == 'ls -l'
  end
end

describe "Kicker, when starting" do
  before do
    @kicker = Kicker.new(:path => '/some/file.rb', :command => 'ls -l')
  end
  
  it "should show the usage banner when path and command are nil and exit" do
    @kicker.path = @kicker.command = nil
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
end