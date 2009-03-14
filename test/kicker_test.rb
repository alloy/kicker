require File.expand_path('../test_helper', __FILE__)

describe "Kicker, when inittializing" do
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