require 'growlnotifier/growl_helpers'

class Kicker
  module Growl
    NOTIFICATIONS = {
      :change => 'Change occured',
      :succeeded => 'Command succeeded',
      :failed => 'Command failed'
    }
    
    DEFAULT_CALLBACK = lambda do
      OSX::NSWorkspace.sharedWorkspace.launchApplication('Terminal')
    end
    
    class << self
      include ::Growl
      attr_accessor :use, :command
      
      Growl.use = true
      Growl.command = nil
      
      def use?
        @use
      end
      
      def notifications
        NOTIFICATIONS
      end
      
      def start!
        ::Growl::Notifier.sharedInstance.register('Kicker', NOTIFICATIONS.values)
      end
      
      def change_occured(status)
        growl(notifications[:change], 'Kicker: Executing', status.call(:growl) || status.command)
      end
      
      def command_callback
        lambda { system(command) } if command
      end
      
      def result(status)
        status.success? ? succeeded(status) : failed(status)
      end
      
      def succeeded(status)
        callback = command_callback || DEFAULT_CALLBACK
        body = status.call(:growl) || (Kicker.silent? ? '' : status.output)
        growl(notifications[:succeeded], "Kicker: Success", body, &callback)
      end
      
      def failed(status)
        message = "Kicker: Failed (#{status.exit_code})"
        body = status.call(:growl) || (Kicker.silent? ? '' : status.output)
        growl(notifications[:failed], message, body, &DEFAULT_CALLBACK)
      end
    end
  end
end