require File.expand_path('../test_helper', __FILE__)

module ReloadDotKick; end

describe "Kicker" do
  before do
    Kicker.any_instance.stubs(:start)
  end
  
  it "should add kicker/recipes to the load path" do
    $:.should.include File.expand_path('../../lib/kicker/recipes', __FILE__)
  end
  
  if File.exist?(File.expand_path('~/.kick'))
    it "should add ~/.kick to the load path" do
      $:.should.include File.expand_path('~/.kick')
    end
  else
    puts "[!] ~/.kick does not exist, skipping an example."
  end
  
  it "should return the default paths to watch" do
    Kicker.paths.should == %w{ . }
  end
  
  it "should check if a .kick file exists and if so load it and add the ReloadDotKick handler" do
    File.expects(:exist?).with('.kick').returns(true)
    Kicker.expects(:require).with('dot_kick')
    ReloadDotKick.expects(:save_state)
    Kicker.expects(:load).with('.kick')
    Kicker.run
  end
  
  it "should check if a recipe exists and load it" do
    Kicker.stubs(:load_dot_kick)
    
    Kicker.expects(:require).with('rails')
    Kicker.expects(:require).with('ignore')
    Kicker.run(%w{ -r rails -r ignore })
  end
  
  it "should raise if a recipe does not exist" do
    Kicker.expects(:require).never
    lambda { Kicker.run(%w{ -r foobar -r rails }) }.should.raise
  end
end

describe "Kicker, when initializing" do
  before do
    @now = Time.now
    Time.stubs(:now).returns(@now)
    
    @kicker = Kicker.new(:paths => %w{ /some/dir a/relative/path })
  end
  
  it "should return the extended paths to watch" do
    @kicker.paths.should == ['/some/dir', File.expand_path('a/relative/path')]
  end
  
  it "should have assigned the current time to last_event_processed_at" do
    @kicker.last_event_processed_at.should == @now
  end
  
  it "should use the default paths if no paths were given" do
    Kicker.new({}).paths.should == [File.expand_path('.')]
  end
  
  it "should use the default FSEvents latency if none was given" do
    @kicker.latency.should == 1
  end
  
  it "should use the given FSEvents latency if one was given" do
    Kicker.new(:latency => 3.5).latency.should == 3.5
  end
end

describe "Kicker, when starting" do
  before do
    @kicker = Kicker.new(:paths => %w{ /some/file.rb })
    @kicker.stubs(:log)
    Rucola::FSEvents.stubs(:start_watching)
    OSX.stubs(:CFRunLoopRun)
  end
  
  it "should show the usage banner and exit when there are no callbacks defined at all" do
    @kicker.stubs(:validate_paths_exist!)
    Kicker.stubs(:process_chain).returns([])
    Kicker.stubs(:pre_process_chain).returns([])
    
    Kicker::OPTION_PARSER_CALLBACK.stubs(:call).returns(mock('OptionParser', :help => 'help'))
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
    
    Rucola::FSEvents.expects(:start_watching).with(['/some'], :latency => @kicker.latency)
    @kicker.start
  end
  
  it "should start a FSEvents stream which watches all paths, but the dirnames of paths if they're files" do
    @kicker.stubs(:validate_options!)
    File.stubs(:directory?).with('/some/file.rb').returns(false)
    
    Rucola::FSEvents.expects(:start_watching).with(['/some'], :latency => @kicker.latency)
    @kicker.start
  end
  
  it "should start a FSEvents stream with a block which calls #process with any generated events" do
    @kicker.stubs(:validate_options!)
    
    Rucola::FSEvents.expects(:start_watching).yields(['event'])
    @kicker.expects(:process).with(['event'])
    
    @kicker.start
  end
  
  it "should setup a signal handler for `INT' which stops the FSEvents stream and exits" do
    @kicker.stubs(:validate_options!)
    
    watch_dog = stub('Rucola::FSEvents')
    Rucola::FSEvents.stubs(:start_watching).returns(watch_dog)
    
    @kicker.expects(:trap).with('INT').yields
    watch_dog.expects(:stop)
    @kicker.expects(:exit)
    
    @kicker.start
  end
  
  it "should register with growl if growl should be used" do
    @kicker.stubs(:validate_options!)
    Kicker.use_growl = true
    
    Growl::Notifier.sharedInstance.expects(:register).with('Kicker', Kicker::GROWL_NOTIFICATIONS.values)
    @kicker.start
  end
  
  it "should _not_ register with growl if growl should not be used" do
    @kicker.stubs(:validate_options!)
    Kicker.use_growl = false
    
    Growl::Notifier.sharedInstance.expects(:register).never
    @kicker.start
  end
  
  it "should call the startup chain" do
    @kicker.stubs(:validate_options!)
    
    @kicker.startup_chain.expects(:call).with([], false)
    @kicker.start
  end
  
  it "should start a CFRunLoop" do
    @kicker.stubs(:validate_options!)
    
    OSX.expects(:CFRunLoopRun)
    @kicker.start
  end
end
