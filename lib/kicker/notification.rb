require 'terminal-notifier'

class Kicker
  module Notification #:nodoc:
    class << self
      attr_accessor :use, :app_bundle_identifier
      alias_method :use?, :use

      def usable?
        TerminalNotifier.available?
      end

      def notify(title, message)
        if usable? && use?
          TerminalNotifier.notify(message, :title => title, :activate => app_bundle_identifier)
        end
      end
    end
  end

  Notification.use = true
  Notification.app_bundle_identifier = 'com.apple.Terminal'
end

