require File.expand_path('../test_helper', __FILE__)

describe "Kicker::Notification" do
  before do
    @notifier = Kicker::Notification
  end

  after do
    Kicker.silent = false
  end

  it "notifies that an event occurred" do
    status = Kicker::Status.new('ls -l')
    @notifier.expects(:notify).with('Kicker: Executing', 'ls -l')
    @notifier.change_occured(status)
  end

  it "only notifies that the command succeeded in silent mode" do
    Kicker.silent = true
    status = Kicker::Status.new('ls -l', 0, "line 1\nline 2")
    @notifier.expects(:notify).with('Kicker: Success', '')
    @notifier.result(status)
  end

  it "only notifies that the command failed in silent mode" do
    Kicker.silent = true
    status = Kicker::Status.new('ls -l', 123, "line 1\nline 2")
    @notifier.expects(:notify).with('Kicker: Failed (123)', '')
    @notifier.failed(status)
  end

  it "calls the terminal-notifier tool and scopes notifications by the current working dir" do
    @notifier.expects(:`).with("'#{Kicker::Notification::TERMINAL_NOTIFICATION_BIN}' #{Dir.pwd} 'the title' 'the message' 'com.apple.Terminal'")
    @notifier.notify('the title', 'the message')
  end
end
