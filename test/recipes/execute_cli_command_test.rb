require File.expand_path('../../test_helper', __FILE__)

describe "Kicker, concerning the `execute a command-line' callback" do
  it "should parse the command and add the callback" do
    before = Kicker.pre_process_chain.length
    
    Kicker.parse_options(%w{ -e ls })
    Kicker.pre_process_chain.length.should == before + 1
    
    Kicker.parse_options(%w{ --execute ls })
    Kicker.pre_process_chain.length.should == before + 2
  end
  
  it "should call execute with the given command" do
    Kicker.parse_options(%w{ -e ls })
    
    callback = Kicker.pre_process_chain.last
    callback.should.be.instance_of Proc
    
    Kicker::Utils.expects(:execute).with('sh -c "ls"')
    
    callback.call(%w{ /file/1 /file/2 }).should.not.be.instance_of Array
  end
  
  it "should clear the files array to halt the chain" do
    Kicker::Utils.stubs(:execute)
    
    files = %w{ /file/1 /file/2 }
    Kicker.pre_process_chain.last.call(files)
    files.should.be.empty
  end
  
  it "should run the command directly once Kicker is done loading" do
    callback = Kicker.pre_process_chain.last
    Kicker.startup_chain.should.include callback
  end
end
