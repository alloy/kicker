require File.expand_path('../spec_helper', __FILE__)

describe "Kicker::Job" do
  before do
    @job = Kicker::Job.new(:command => 'ls -l', :exit_code => 0, :output => "line 1\nline2")
  end

  after do
    Kicker.silent = true
  end

  it "initializes with an options hash" do
    @job.command.should == 'ls -l'
    @job.exit_code.should == 0
    @job.output.should == "line 1\nline2"
  end

  it "returns wether or not the job was a success" do
    @job.should.be.success
    @job.exit_code = 123
    @job.should.not.be.success
  end

  describe "concerning the default print and notification messages" do
    describe "for before a command is executed" do
      it "returns what command will be executed (for print)" do
        @job.print_before.should == 'Executing: ls -l'
      end

      it "returns what command will be executed (for notification)" do
        Kicker.silent = false
        @job.notify_before.should == { :title => 'Kicker: Executing', :message => 'ls -l' }
      end

      # TODO what if the user *does* want to send a notification?
      #it "does not send a notification about what command will be executed if Kicker is silent" do
        #Kicker.silent = true
        #@job.notify_before.should == nil
      #end
    end

    describe "for after a command is executed" do
      describe "for print" do
        it "does not return the output if the output has already been logged" do
          Kicker.silent = false
          @job.exit_code = 123
          @job.print_after.should == nil
        end

        it "does not return the output if the command succeeded" do
          Kicker.silent = true
          @job.exit_code = 0
          @job.print_after.should == nil
        end

        it "returns all output if it wasn't printed before and the command failed" do
          Kicker.silent = true
          @job.exit_code = 123
          @job.print_after.should == "\nline 1\nline2\n\n"
        end
      end

      describe "for notification" do
        it "returns the status of the command and its output" do
          Kicker.silent = false
          @job.exit_code = 0
          @job.notify_after.should == { :title => 'Kicker: Success', :message => "line 1\nline2" }
          @job.exit_code = 123
          @job.notify_after.should == { :title => 'Kicker: Failed (123)', :message => "line 1\nline2" }
        end

        it "never returns the output if Kicker is silent" do
          Kicker.silent = true
          @job.exit_code = 0
          @job.notify_after.should == { :title => 'Kicker: Success', :message => '' }
          @job.exit_code = 123
          @job.notify_after.should == { :title => 'Kicker: Failed (123)', :message => '' }
        end
      end
    end
  end

  describe "concerning explicit print and notification messages" do
    it "returns `nil' if that was explicitely assigned" do
      %w{ print_before print_after notify_before notify_after }.each do |attr|
        @job.send("#{attr}=", nil)
        @job.send(attr).should == nil
      end
    end

    it "returns the assigned message when explicitely assigned" do
      @job.print_before = 'BEFORE'
      @job.print_before.should == 'BEFORE'
      @job.print_after = 'AFTER'
      @job.print_after.should == 'AFTER'
    end

    it "merges the assigned notification options with the default ones" do
      @job.notify_before = { :message => 'Checking file list' }
      @job.notify_before.should == { :title => 'Kicker: Executing', :message => 'Checking file list' }
      @job.notify_after = { :title => 'OMG' }
      @job.notify_after.should == { :title => 'OMG', :message => "line 1\nline 2" }
    end
  end
end
