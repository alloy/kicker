require File.expand_path('../test_helper', __FILE__)

describe "Kicker::LogStatus" do
  yielded = nil
  
  before do
    @status = Kicker::LogStatusHelper.new(proc { |s| yielded = s; 'out' if s.growl? }, 'ls -l')
  end
  
  it "should return whether or not it's for a stdout logger" do
    @status.call(:stdout)
    yielded.should.be.stdout
    yielded.should.not.be.growl
  end
  
  it "should return whether or not it's for a growl logger" do
    @status.call(:growl)
    yielded.should.not.be.stdout
    yielded.should.be.growl
  end
  
  it "should return the command" do
    @status.call(:growl)
    yielded.command.should == 'ls -l'
  end
  
  it "should return if it's before executing the command" do
    @status.call(:growl)
    yielded.should.be.before
    yielded.should.be.not.after
  end
  
  it "should return if it's after executing the command" do
    @status.result('output', true, 0)
    @status.call(:growl)
    yielded.should.not.be.before
    yielded.should.be.after
  end
  
  it "should return the output and status" do
    @status.result('output', true, 123)
    @status.call(:growl)
    yielded.output.should == "output"
    yielded.should.be.success
    yielded.exit_code.should.be 123
  end
  
  it "should set the logger type, call the proc with self, and return the output" do
    @status.call(:growl).should == "out"
  end
  
  it "should not try to call the block if none was given and return nil" do
    status = Kicker::LogStatusHelper.new(nil, 'ls -l')
    status.call(:growl).should.be nil
  end
end