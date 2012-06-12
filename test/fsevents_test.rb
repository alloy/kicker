require File.expand_path('../test_helper', __FILE__)

class FakeListener
  def initialize(paths, options={})
    @paths = paths
  end
  
  def change(&block)
    @block = block
    self
  end
  
  def start blocking=true
    self
  end
  
  def fake_event(paths)
    @block.call(paths)
  end
end

describe "Kicker::FSEvents" do
  it "calls the provided block with changed directories wrapped in an event instance" do
    all_paths = %w(/path/to/first /path/to/second)
    faker = FakeListener.new all_paths
    Listen.expects(:to).with(*(all_paths.dup << {})).returns(faker)

    events = nil
    Kicker::FSEvents.start_watching(all_paths) { |e| events = e }

    faker.fake_event(%w(/path/to/first/file))
    events.map { |e| e.path }.should == %w(/path/to/first)
  end
end

describe "Kicker::FSEvents::FSEvent" do
  it "returns the files from the changed directory ordered by mtime and filename" do
    fsevent = Kicker::FSEvents::FSEvent.new(File.expand_path('../fixtures', __FILE__))
    fsevent.files.should == [File.expand_path('../fixtures/a_file_thats_reloaded.rb', __FILE__)]
  end
end
