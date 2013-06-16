require 'notify'

class Kicker
  module Notification #:nodoc:
    TITLE = 'Kicker'

    class << self
      attr_accessor :use, :app_bundle_identifier
      alias_method :use?, :use

      def notify(options)
        return unless use?

        unless message = options.delete(:message)
          raise "A notification requires a `:message'"
        end

        options = {
          :group    => Dir.pwd,
          :activate => app_bundle_identifier
        }.merge(options)

        Notify.notify(TITLE, message, options)
      end
    end
  end

  Notification.use = true
  Notification.app_bundle_identifier = 'com.apple.Terminal'
end

