class Kicker
  module Notification #:nodoc:
    vendor = File.expand_path('../../../vendor', __FILE__)
    TERMINAL_NOTIFICATION_BIN = File.join(vendor, 'terminal-notifier_v1.0/terminal-notifier.app/Contents/MacOS/terminal-notifier')

    class << self
      attr_accessor :use, :app_bundle_identifier
      alias_method :use?, :use

      def usable?
        @usable ||= `uname`.strip == 'Darwin' && `sw_vers -productVersion`.strip >= '10.8'
      end

      def notify(title, message)
        if usable? && use?
          `'#{TERMINAL_NOTIFICATION_BIN}' #{Dir.pwd} '#{title}' '#{message}' '#{app_bundle_identifier}'`
        end
      end
    end
  end

  Notification.use = true
  Notification.app_bundle_identifier = 'com.apple.Terminal'
end

