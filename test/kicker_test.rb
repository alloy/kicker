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
  
  it "should show the usage banner when path and command are nil" do
    @kicker.path = @kicker.command = nil
    
    @kicker.expects(:puts).with("Usage: #{$0} [PATH] [COMMAND]")
    @kicker.expects(:exit)
    
    @kicker.start
  end
end