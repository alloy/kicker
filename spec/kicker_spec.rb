require File.expand_path('../spec_helper', __FILE__)

describe "Kicker" do
  it "should start" do
    thread = Thread.new { Kicker.run }
    thread.abort_on_exception = true
    sleep 5
    thread.alive?.should == true
    thread.exit
  end
end
