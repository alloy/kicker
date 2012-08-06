require File.expand_path('../test_helper', __FILE__)

describe "Kicker::Job" do
  before do
    @job = Kicker::Job.new(:command => 'ls -l', :exit_code => 0, :output => "line 1\nline2")
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
      it "returns what command will be executed, before executing a command" do
        @job.print_before.should == 'Executing: ls -l'
      end
    end

    describe "for after a command is executed" do
      it "does not return the output if the output has already been logged" do
        Kicker.silent = false
        @job.exit_code.should == 123
        @job.print_after.should == nil
      end

      it "does not return the output if the command succeeded" do
        Kicker.silent = true
        @job.exit_code.should == 0
        @job.print_after.should == nil
      end

      it "returns all output if it wasn't printed before and the command failed" do
        Kicker.silent = true
        @job.exit_code.should == 123
        @job.print_after.should == "\nline 1\nline2\n\n"
      end
    end
  end
end
