require File.expand_path('../spec_helper', __FILE__)
require 'stringio'

describe "Kicker" do
  before { @stdout = $stdout }
  after { $stdout = @stdout }

  it "should start" do
    $stdout = StringIO.new
    thread = Thread.new { Kicker.run([]) }
    thread.abort_on_exception = true
    sleep 5
    thread.alive?.should == true
    thread.exit
  end
end
