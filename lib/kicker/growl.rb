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
      
      def change_occured(command)
        growl(notifications[:change], 'Kicker: Executing:', command)
      end
      
      def command_callback
        lambda { system(command) } if command
      end
      
      def result(output)
        Kicker::Utils.last_command_succeeded? ? succeeded(output) : failed(output)
      end
      
      def succeeded(output)
        callback = command_callback || DEFAULT_CALLBACK
        body = Kicker.silent? ? '' : output
        growl(notifications[:succeeded], "Kicker: Success", body, &callback)
      end
      
      def failed(output)
        message = "Kicker: Failed (#{Kicker::Utils.last_command_status})"
        body = Kicker.silent? ? '' : output
        growl(notifications[:failed], message, body, &DEFAULT_CALLBACK)
      end
    end
  end
end