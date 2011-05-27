class Kicker
  module Growl #:nodoc:
    class << self
      attr_accessor :use, :command
      
      def usable?
        false
      end
      
      def use?
        @use
      end
    end
  end
end

if Kernel.const_defined?(:OSX)
  class Kicker
    module Growl #:nodoc:
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
        
        Growl.use = true
        Growl.command = nil
        
        def usable?
          true
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
end