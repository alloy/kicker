require File.expand_path('../spec_helper', __FILE__)

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
    @block.call(paths, [], [])
  end
end

describe "Kicker::FSEvents" do
  it "calls the provided block with changed directories wrapped in an event instance" do
    tmp = Pathname.new('tmp').join('test')
    test = tmp.join('what')
    test.mkpath

    FileUtils.touch(tmp.join('file'))

    watch_dog = Kicker::FSEvents.start_watching([tmp.to_s]) { |e| events = e }
    Kicker::FSEvents::FSEvent.expects(:new).with('what')

    FileUtils.touch(test.join('file'))

    sleep 1
  end
end

describe "Kicker::FSEvents::FSEvent" do
  it "returns the files from the changed directory ordered by mtime and filename" do
    fsevent = Kicker::FSEvents::FSEvent.new(File.expand_path('../fixtures', __FILE__))
    fsevent.files.should == [File.expand_path('../fixtures/a_file_thats_reloaded.rb', __FILE__)]
  end
end
