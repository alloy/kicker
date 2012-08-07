require File.expand_path('../spec_helper', __FILE__)

class Kicker
  module Utils
    public :will_execute_command, :did_execute_command
  end
end

describe "A Kicker instance, concerning its utility methods" do
  def utils
    Kicker::Utils
  end

  before do
    utils.stubs(:puts)
    Kicker::Notification.use = false
    Kicker::Notification.stubs(:`)
  end
  
  after do
    Kicker.silent = false
    Kicker::Notification.use = true
  end
  
  it "should print a log entry with timestamp" do
    now = Time.now
    Time.stubs(:now).returns(now)
    
    utils.expects(:puts).with("#{now.strftime('%H:%M:%S')}.#{now.usec.to_s[0,2]} | the message")
    utils.send(:log, 'the message')
  end
  
  it 'should print a log entry with no timestamp in quiet mode' do
    before = Kicker.quiet
    
    utils.expects(:puts).with('the message')
    
    Kicker.quiet = true
    utils.send(:log, 'the message')
    
    Kicker.quiet = before
  end
  
  it "logs that the command succeeded" do
    utils.stubs(:_execute).with do |job|
      job.output = "line 1\nline 2"
      job.exit_code = 0
    end
    utils.expects(:log).with('Executing: ls')
    utils.expects(:log).with('Success')
    utils.execute('ls')
  end

  it "logs that the command failed" do
    utils.stubs(:_execute).with do |job|
      job.output = "line 1\nline 2"
      job.exit_code = 123
    end
    utils.expects(:log).with('Executing: ls')
    utils.expects(:log).with('Failed (123)')
    utils.execute('ls')
  end

  it "calls the block given to execute and yields the job so the user can transform the output" do
    Kicker.silent = true

    utils.stubs(:_execute).with do |job|
      job.output = "line 1\nline 2"
      job.exit_code = 123
    end

    utils.expects(:log).with('Executing: ls -l')
    utils.expects(:puts).with("\nOhnoes!\n\n")
    utils.expects(:log).with('Failed (123)')

    utils.execute('ls -l') do |job|
      job.output = job.success? ? 'Done!' : 'Ohnoes!'
    end
  end

  before do
    Kicker::Notification.use = true
  end

  it "notifies that a change occurred and shows the command and then the output" do
    utils.stubs(:log)
    utils.stubs(:_execute).with do |job|
      job.output = "line 1\nline 2"
    end 
    Kicker::Notification.expects(:notify).with(:title => 'Kicker: Executing', :message => "ls")
    Kicker::Notification.expects(:notify).with(:title => 'Kicker: Success', :message => "line 1\nline 2")
    utils.execute('ls')
  end
  
  it "does not notify that a change occured in silent mode" do
    Kicker.silent = true
    utils.stubs(:did_execute_command)
    
    utils.expects(:log)
    Kicker::Notification.expects(:change_occured).never
    utils.execute('ls')
  end
  
  it "only logs that it has succeeded in silent mode" do
    Kicker.silent = true
    Kicker::Notification.expects(:notify).with(:title => "Kicker: Success", :message => "")
    
    job = Kicker::Job.new(:command => 'ls -l', :exit_code => 0, :output => "line 1\nline 2")
    
    utils.expects(:log).with("Success")
    utils.did_execute_command(job)
  end
  
  it "fully logs that it has failed in silent mode" do
    Kicker.silent = true
    Kicker::Notification.expects(:notify).with(:title => "Kicker: Failed (123)", :message => "")
    
    utils.expects(:puts).with("\nline 1\nline 2\n\n")
    utils.expects(:log).with('Failed (123)')
    
    job = Kicker::Job.new(:command => 'ls -l', :exit_code => 123, :output => "line 1\nline 2")
    utils.did_execute_command(job)
  end
end

describe "Kernel utility methods" do
  def utils
    Kicker::Utils
  end

  it "should forward log calls to the Kicker::Utils module" do
    utils.expects(:log).with('the message')
    log 'the message'
  end
  
  it "should forward execute calls to the Kicker::Utils module" do
    utils.expects(:execute).with('ls')
    execute 'ls'
  end
end
