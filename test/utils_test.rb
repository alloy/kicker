require File.expand_path('../test_helper', __FILE__)

Kicker::Utils.send(:public, :did_execute_command)

describe "A Kicker instance, concerning its utility methods" do
  before do
    utils.stubs(:puts)
  end
  
  after do
    Kicker.silent = false
    Kicker::Growl.use = true
  end
  
  it "should print a log entry with timestamp" do
    now = Time.now
    Time.stubs(:now).returns(now)
    
    utils.expects(:puts).with("#{now.strftime('%H:%M:%S')}.#{now.usec.to_s[0,2]} | the message")
    utils.send(:log, 'the message')
  end
  
  it "should log the output of the command indented by 2 spaces and whether or not the command succeeded" do
    Kicker::Growl.use = false
    
    utils.stubs(:`).returns("line 1\nline 2")
    
    utils.stubs(:last_command_succeeded?).returns(true)
    utils.expects(:log).with('Executing: ls')
    utils.expects(:puts).with("\nline 1\nline 2\n\n")
    utils.expects(:log).with('Success')
    utils.execute('ls')
    
    utils.stubs(:last_command_succeeded?).returns(false)
    utils.stubs(:last_command_status).returns(123)
    utils.expects(:log).with('Executing: ls')
    utils.expects(:puts).with("\nline 1\nline 2\n\n")
    utils.expects(:log).with('Failed (123)')
    utils.execute('ls')
  end
  
  it "should growl a change occurred and the output" do
    utils.stubs(:`).returns("line 1\nline 2")
    utils.stubs(:last_command_succeeded?).returns(true)
    utils.stubs(:log)
    
    Kicker::Growl.expects(:change_occured).with('ls')
    Kicker::Growl.expects(:result).with("line 1\nline 2")
    utils.execute('ls')
  end
  
  it "should not growl that a change occured in silent mode" do
    Kicker.silent = true
    utils.stubs(:did_execute_command)
    
    utils.expects(:log)
    Kicker::Growl.expects(:change_occured).never
    utils.execute('ls')
  end
  
  it "should only log that is has succeeded in silent mode" do
    Kicker.silent = true
    Kicker::Growl.expects(:result).with("line 1\nline 2")
    
    status = Kicker::LogStatusHelper.new(nil, 'ls -l')
    status.result("line 1\nline 2", true)
    
    utils.expects(:log).with("Success")
    utils.did_execute_command(status)
  end
  
  it "should fully log that it has failed in silent mode" do
    Kicker.silent = true
    Kicker::Growl.expects(:result).with("line 1\nline 2")
    
    utils.stubs(:last_command_status).returns(123)
    utils.expects(:puts).with("\nline 1\nline 2\n\n")
    utils.expects(:log).with('Failed (123)')
    
    status = Kicker::LogStatusHelper.new(nil, 'ls -l')
    status.result("line 1\nline 2", false)
    
    utils.did_execute_command(status)
  end
  
  it "should store the last executed command" do
    Kicker::Growl.use = false
    utils.stubs(:log)
    
    utils.execute('date')
    utils.last_command.should == 'date'
  end
  
  it "should call the block given to execute when and yield the log status helper with status success" do
    Kicker.silent = true
    Kicker::Growl.use = false
    utils.stubs(:last_command_succeeded?).returns(true)
    
    utils.expects(:log).with('Start!')
    utils.expects(:log).with('Done!')
    
    utils.execute('ls -l') do |status|
      if status.after?
        if status.success?
          'Done!'
        else
          'Ohnoes!'
        end
      elsif status.before?
        'Start!'
      end
    end
  end
  
  it "should call the block given to execute when and yield the log status helper with status failed" do
    Kicker.silent = true
    Kicker::Growl.use = false
    utils.stubs(:last_command_succeeded?).returns(false)
    
    utils.expects(:log).with('Start!')
    utils.expects(:log).with('Ohnoes!')
    
    utils.execute('ls -l') do |status|
      if status.after?
        if status.success?
          'Done!'
        else
          'Ohnoes!'
        end
      elsif status.before?
        'Start!'
      end
    end
  end
  
  private
  
  def utils
    Kicker::Utils
  end
end

describe "Kernel utility methods" do
  before do
    utils.stubs(:last_command_succeeded?).returns(true)
  end
  
  it "should forward log calls to the Kicker::Utils module" do
    utils.expects(:log).with('the message')
    log 'the message'
  end
  
  it "should forward execute calls to the Kicker::Utils module" do
    utils.expects(:execute).with('ls')
    execute 'ls'
  end
  
  it "should return the last_command" do
    utils.stubs(:last_command).returns('abcde')
    last_command.should == 'abcde'
  end
  
  it "should call execute with the appropriate command to execute Ruby tests" do
    utils.expects(:execute).with("ruby -r test/1.rb -r test/2.rb -e ''")
    run_ruby_tests %w{ test/1.rb test/2.rb }
  end
  
  it "should not execute anything if an empty array is given to run_ruby_tests" do
    utils.expects(:execute).never
    run_ruby_tests []
  end
  
  it "should use an alternative ruby when specified" do
    utils.stubs(:ruby_bin_path).returns('/opt/ruby-1.9.2/bin/ruby')
    utils.expects(:execute).with("/opt/ruby-1.9.2/bin/ruby -r test/1.rb -r test/2.rb -e ''")
    run_ruby_tests %w{ test/1.rb test/2.rb }
  end
  
  private
  
  def utils
    Kicker::Utils
  end
end

describe "Kicker::Utils" do
  it "should have an accessor for the ruby binary path" do
    before = Kicker::Utils.ruby_bin_path
    alternative = '/opt/ruby-1.9.2/bin/ruby'
    
    Kicker::Utils.ruby_bin_path = alternative
    Kicker::Utils.ruby_bin_path.should == alternative
    Kicker::Utils.ruby_bin_path = before
  end
end