require 'growlnotifier/growl_helpers'

class Kicker
  include Growl
  
  attr_accessor :use_growl, :growl_command
  
  GROWL_NOTIFICATIONS = {
    :change => 'Change occured',
    :succeeded => 'Command succeeded',
    :failed => 'Command failed'
  }
  
  GROWL_DEFAULT_CALLBACK = lambda do
    OSX::NSWorkspace.sharedWorkspace.launchApplication('Terminal')
  end
  
  private
  
  def start_growl!
    Growl::Notifier.sharedInstance.register('Kicker', Kicker::GROWL_NOTIFICATIONS.values)
  end
end