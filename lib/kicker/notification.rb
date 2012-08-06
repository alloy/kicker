require 'terminal-notifier'

class Kicker
  module Notification #:nodoc:
    class << self
      attr_accessor :use, :app_bundle_identifier
      alias_method :use?, :use

      def usable?
        TerminalNotifier.available?
      end

      def notify(options)
        if usable? && use?
          unless message = options.delete(:message)
            raise "A notification requires a `:message'"
          end
          options = {
            :group    => Dir.pwd,
            :activate => app_bundle_identifier
          }.merge(options)
          TerminalNotifier.notify(message, options)
        end
      end
    end
  end

  Notification.use = true
  Notification.app_bundle_identifier = 'com.apple.Terminal'
end

