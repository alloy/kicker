require File.expand_path('../../test_helper', __FILE__)

describe "Kicker, concerning the `execute a command-line' callback" do
  it "should parse the command and add the callback" do
    before = Kicker.process_chain.length
    
    Kicker.parse_options(%w{ -e ls })
    Kicker.process_chain.length.should == before + 1
    
    Kicker.parse_options(%w{ --execute ls })
    Kicker.process_chain.length.should == before + 2
  end
  
  it "should call execute_command with the given command" do
    Kicker.parse_options(%w{ -e ls })
    
    callback = Kicker.process_chain.last
    callback.should.be.instance_of Proc
    
    kicker = Kicker.new({})
    kicker.expects(:execute_command).with('sh -c "ls"')
    
    callback.call(kicker, %w{ /file/1 /file/2 }).should.not.be.instance_of Array
  end
end