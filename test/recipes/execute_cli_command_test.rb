require File.expand_path('../../test_helper', __FILE__)

describe "Kicker, concerning the `execute a command-line' callback" do
  it "should parse the command and add the callback" do
    before = Kicker.pre_process_chain.length
    
    Kicker.parse_options(%w{ -e ls })
    Kicker.pre_process_chain.length.should == before + 1
    
    Kicker.parse_options(%w{ --execute ls })
    Kicker.pre_process_chain.length.should == before + 2
  end
  
  it "should call execute_command with the given command" do
    Kicker.parse_options(%w{ -e ls })
    
    callback = Kicker.pre_process_chain.last
    callback.should.be.instance_of Proc
    
    kicker = Kicker.new({})
    kicker.expects(:execute_command).with('sh -c "ls"')
    
    callback.call(kicker, %w{ /file/1 /file/2 }).should.not.be.instance_of Array
  end
  
  it "should clear the files array to halt the chain" do
    files = %w{ /file/1 /file/2 }
    Kicker.pre_process_chain.last.call(stub(:execute_command), files)
    files.should.be.empty
  end
end
