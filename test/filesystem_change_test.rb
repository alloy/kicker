require File.expand_path('../test_helper', __FILE__)

describe "Kicker, when a change occurs" do
  before do
    Kicker.any_instance.stubs(:last_command_succeeded?).returns(true)
    Kicker.any_instance.stubs(:log)
    @kicker = Kicker.new({})
  end
  
  it "should store the current time as when the last change occurred" do
    now = Time.now
    Time.stubs(:now).returns(now)
    
    @kicker.send(:finished_processing!)
    @kicker.last_event_processed_at.should.be now
  end
  
  it "should return an array of files that have changed since the last event" do
    file1 = touch('1')
    file2 = touch('2')
    file3 = touch('3')
    file4 = touch('4')
    @kicker.send(:finished_processing!)
    
    events = [event(file1, file2), event(file3, file4)]
    
    @kicker.send(:changed_files, events).should == []
    @kicker.send(:finished_processing!)
    
    sleep(1)
    touch('2')
    
    @kicker.send(:changed_files, events).should == [file2]
    @kicker.send(:finished_processing!)
    
    sleep(1)
    touch('1')
    touch('3')
    
    @kicker.send(:changed_files, events).should == [file1, file3]
  end
  
  it "should run the callback chain with all changed files" do
    files = %w{ /file/1 /file/2 }
    events = [event('/file/1'), event('/file/2')]
    
    @kicker.expects(:changed_files).with(events).returns(files)
    @kicker.process_chain.expects(:run).with(@kicker, files)
    @kicker.expects(:finished_processing!)
    
    @kicker.send(:process, events)
  end
  
  it "should not run the callback chain if there were no changed files" do
    @kicker.stubs(:changed_files).returns([])
    @kicker.process_chain.expects(:run).never
    @kicker.expects(:finished_processing!).never
    
    @kicker.send(:process, [event()])
  end
  
  private
  
  def touch(file)
    file = "/tmp/kicker_test_tmp_#{file}"
    `touch #{file}`
    file
  end
  
  def event(*files)
    event = stub('FSEvent')
    event.stubs(:files).returns(files)
    event
  end
end
