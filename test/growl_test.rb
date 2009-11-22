require File.expand_path('../test_helper', __FILE__)

describe "Kicker::Growl" do
  before do
    @growler = Kicker::Growl
  end
  
  after do
    Kicker.silent = false
  end
  
  it "should use the default click callback if a command succeeded and no user callback is defined" do
    Kicker::Utils.stubs(:last_command_succeeded?).returns(true)
    
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal')
    @growler.expects(:growl).with(
      @growler.notifications[:succeeded],
      'Kicker: Success',
      "line 1\nline 2"
    ).yields
    
    @growler.succeeded("line 1\nline 2")
  end
  
  it "should use the default click callback if a command failed and no user callback is defined" do
    Kicker::Utils.stubs(:last_command_succeeded?).returns(false)
    Kicker::Utils.stubs(:last_command_status).returns(123)
    
    OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal')
    @growler.expects(:growl).with(
      @growler.notifications[:failed],
      'Kicker: Failed (123)',
      "line 1\nline 2"
    ).yields
    
    @growler.failed("line 1\nline 2")
  end
  
  it "should only growl that the command succeeded in silent mode" do
    Kicker.silent = true
    Kicker::Utils.stubs(:last_command_succeeded?).returns(true)
    
    @growler.expects(:growl).with(@growler.notifications[:succeeded], 'Kicker: Success', '')
    @growler.succeeded("line 1\nline 2")
  end
  
  it "should only growl that the command failed in silent mode" do
    Kicker.silent = true
    Kicker::Utils.stubs(:last_command_succeeded?).returns(false)
    Kicker::Utils.stubs(:last_command_status).returns(123)
    
    @growler.expects(:growl).with(@growler.notifications[:failed], 'Kicker: Failed (123)', '')
    @growler.failed("line 1\nline 2")
  end
end