require File.expand_path('../spec_helper', __FILE__)

module ReloadDotKick; end

describe "Kicker" do
  before do
    Kicker.any_instance.stubs(:start)
  end
  
  it "should return the default paths to watch" do
    Kicker.paths.should == %w{ . }
  end
  
  it "should default the FSEvents latency to 1" do
    Kicker.latency.should == 1
  end
end

describe "Kicker, when initializing" do
  after do
    Kicker.paths = %w{ . }
  end
  
  it "should return the extended paths to watch" do
    Kicker.paths = %w{ /some/dir a/relative/path }
    Kicker.new.paths.should == ['/some/dir', File.expand_path('a/relative/path')]
  end
  
  it "should have assigned the current time to last_event_processed_at" do
    now = Time.now; Time.stubs(:now).returns(now)
    Kicker.new.last_event_processed_at.should == now
  end
  
  it "should use the default paths if no paths were given" do
    Kicker.new.paths.should == [File.expand_path('.')]
  end
end

describe "Kicker, when starting" do
  before do
    Kicker.paths = %w{ /some/file.rb }
    @kicker = Kicker.new
    @kicker.stubs(:log)
    @kicker.startup_chain.stubs(:call)
    Kicker::FSEvents.stubs(:start_watching)
  end
  
  after do
    Kicker.latency = 1
    Kicker.paths = %w{ . }
  end
  
  it "should show the usage banner and exit when there are no callbacks defined at all" do
    @kicker.stubs(:validate_paths_exist!)
    Kicker.stubs(:startup_chain).returns(Kicker::CallbackChain.new)
    Kicker.stubs(:process_chain).returns(Kicker::CallbackChain.new)
    Kicker.stubs(:pre_process_chain).returns(Kicker::CallbackChain.new)
    
    Kicker::Options.stubs(:parser).returns(mock('OptionParser', :help => 'help'))
    @kicker.expects(:puts).with("help")
    @kicker.expects(:exit)
    
    @kicker.start
  end
  
  it "should warn the user and exit if any of the given paths doesn't exist" do
    @kicker.stubs(:validate_paths_and_command!)
    
    @kicker.expects(:puts).with("The given path `/some/file.rb' does not exist")
    @kicker.expects(:exit).with(1)
    
    @kicker.start
  end
  
  it "should start a FSEvents stream with the assigned latency" do
    @kicker.stubs(:validate_options!)
    
    Kicker.latency = 2.34
    Kicker::FSEvents.expects(:start_watching).with(['/some'], :latency => 2.34)
    @kicker.start
  end
  
  it "should start a FSEvents stream which watches all paths, but the dirnames of paths if they're files" do
    @kicker.stubs(:validate_options!)
    File.stubs(:directory?).with('/some/file.rb').returns(false)
    
    Kicker::FSEvents.expects(:start_watching).with(['/some'], :latency => Kicker.latency)
    @kicker.start
  end
  
  it "should start a FSEvents stream with a block which calls #process with any generated events" do
    @kicker.stubs(:validate_options!)
    
    Kicker::FSEvents.expects(:start_watching).yields(['event'])
    @kicker.expects(:process).with(['event'])
    
    @kicker.start
  end
  
  it "should setup a signal handler for `INT' which stops the FSEvents stream and exits" do
    @kicker.stubs(:validate_options!)
    
    watch_dog = stub('Kicker::FSEvents')
    Kicker::FSEvents.stubs(:start_watching).returns(watch_dog)
    
    @kicker.expects(:trap).with('INT').yields
    watch_dog.expects(:stop)
    @kicker.expects(:exit)
    
    @kicker.start
  end
 
  it "should call the startup chain" do
    @kicker.stubs(:validate_options!)
    
    @kicker.startup_chain.expects(:call).with([], false)
    @kicker.start
  end
end
