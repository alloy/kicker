require File.expand_path('../../spec_helper', __FILE__)

describe "Kicker, concerning the default `could not handle file' callback" do
  after do
    Kicker.silent = false
  end
  
  it "should log that it could not handle the given files" do
    Kicker::Utils.expects(:log).with('')
    Kicker::Utils.expects(:log).with("Could not handle: /file/1, /file/2")
    Kicker::Utils.expects(:log).with('')
    
    Kicker.post_process_chain.last.call(%w{ /file/1 /file/2 })
  end
  
  it "should not log in silent mode" do
    Kicker.silent = true
    Kicker::Utils.expects(:log).never
    Kicker.post_process_chain.last.call(%w{ /file/1 /file/2 })
  end
end
