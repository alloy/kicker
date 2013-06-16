require File.expand_path('../spec_helper', __FILE__)

describe "Kicker::Notification" do
  it "sends a notification, grouped by the project (identified by the working dir)" do
    Notify.expects(:notify)
    Kicker::Notification.notify(:title => 'Kicker: Executing', :message => 'ls -l')
  end

  it "does not send a notification if notifying is disabled" do
    Kicker::Notification.stubs(:use?).returns(false)
    Notify.expects(:notify).never
    Kicker::Notification.notify(:title => 'Kicker: Executing', :message => 'ls -l')
  end
end
