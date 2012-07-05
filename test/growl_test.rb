require File.expand_path('../test_helper', __FILE__)

if Kicker::Growl.usable?
  describe "Kicker::Growl" do
    before do
      @growler = Kicker::Growl
    end
    
    after do
      Kicker.silent = false
    end
    
    it "should growl that an event occurred" do
      status = Kicker::Status.new('ls -l')
      @growler.expects(:growl).with(@growler.notifications[:change], 'Kicker: Executing', 'ls -l')
      @growler.change_occured(status)
    end
    
    it "should use the default click callback if a command succeeded" do
      status = Kicker::Status.new('ls -l', 0, "line 1\nline 2")

      OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal')
      @growler.expects(:growl).with(
        @growler.notifications[:succeeded],
        'Kicker: Success',
        "line 1\nline 2"
      ).yields

      @growler.result(status)
    end
    
    it "should use the default click callback if a command failed" do
      status = Kicker::Status.new('ls -l', 123, "line 1\nline 2")

      OSX::NSWorkspace.sharedWorkspace.expects(:launchApplication).with('Terminal')
      @growler.expects(:growl).with(
        @growler.notifications[:failed],
        'Kicker: Failed (123)',
        "line 1\nline 2"
      ).yields

      @growler.failed(status)
    end

    it "should only growl that the command succeeded in silent mode" do
      Kicker.silent = true
      status = Kicker::Status.new('ls -l', 0, "line 1\nline 2")
      @growler.expects(:growl).with(@growler.notifications[:succeeded], 'Kicker: Success', '')
      @growler.result(status)
    end

    it "should only growl that the command failed in silent mode" do
      Kicker.silent = true
      status = Kicker::Status.new('ls -l', 123, "line 1\nline 2")
      @growler.expects(:growl).with(@growler.notifications[:failed], 'Kicker: Failed (123)', '')
      @growler.failed(status)
    end
  end
end
