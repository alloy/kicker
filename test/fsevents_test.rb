require File.expand_path('../test_helper', __FILE__)

class FakeFSEvent
  def watch(paths, options={}, &block)
    @paths = paths
    @block = block
  end
  
  def run
  end
  
  def fake_event(paths)
    @block.call(paths)
  end
end

describe "Kicker::FSEvents" do
  it "calls the provided block with changed directories wrapped in an event instance" do
    events = nil
    faker = FakeFSEvent.new
    ::FSEvent.expects(:new).returns(faker)
    Kicker::FSEvents.start_watching(%w(/path/to/first /path/to/second)) { |e| events = e }
    paths = %w(/path/to/first)
    faker.fake_event(paths)
    events.map { |e| e.path }.should == paths
  end
end

describe "Kicker::FSEvents::FSEvent" do
  it "returns the files from the changed directory ordered by mtime and filename" do
    fsevent = Kicker::FSEvents::FSEvent.new(File.expand_path('../fixtures', __FILE__))
    fsevent.files.should == [File.expand_path('../fixtures/a_file_thats_reloaded.rb', __FILE__)]
  end
end
