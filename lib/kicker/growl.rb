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
      attr_accessor :use_growl, :growl_command
      
      def notifications
        NOTIFICATIONS
      end
      
      def use?
        @use_growl
      end
      
      def start!
        ::Growl::Notifier.sharedInstance.register('Kicker', NOTIFICATIONS.values)
      end
      
      def change_occured(command)
        growl(notifications[:change], 'Kicker: Change occured, executing command:', command)
      end
      
      def command
        lambda { system(growl_command) } if growl_command
      end
      
      def result(output)
        Kicker::Utils.last_command_succeeded? ? succeeded(output) : failed(output)
      end
      
      def succeeded(output)
        callback = command || DEFAULT_CALLBACK
        growl(notifications[:succeeded], "Kicker: Command succeeded", output, &callback)
      end
      
      def failed(output)
        message = "Kicker: Command failed (#{Kicker::Utils.last_command_status})"
        growl(notifications[:failed], message, output, &DEFAULT_CALLBACK)
      end
    end
  end
end