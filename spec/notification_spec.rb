require File.expand_path('../spec_helper', __FILE__)

describe "Kicker::Notification" do
  it "sends a notification, grouped by the project (identified by the working dir)" do
    TerminalNotifier.stubs(:available?).returns(true)
    TerminalNotifier.expects(:notify).with('ls -l', :title => 'Kicker: Executing', :group => Dir.pwd, :activate => 'com.apple.Terminal')
    Kicker::Notification.notify(:title => 'Kicker: Executing', :message => 'ls -l')
  end

  it "does not send a notification if TerminalNotifier is not available" do
    TerminalNotifier.stubs(:available?).returns(false)
    TerminalNotifier.expects(:notify).never
    Kicker::Notification.notify(:title => 'Kicker: Executing', :message => 'ls -l')
  end

  it "does not send a notification if notifying is disabled" do
    TerminalNotifier.stubs(:available?).returns(true)
    Kicker::Notification.use = false
    TerminalNotifier.expects(:notify).never
    Kicker::Notification.notify(:title => 'Kicker: Executing', :message => 'ls -l')
  end
end
