class Kicker
  class Job
    def self.attr_with_default(name, &default)
      # If `nil` this returns the `default`, unless explicitely set to `nil` by
      # the user.
      define_method(name) do
        options = instance_eval(&default)
        if instance_variable_get("@#{name}_assigned")
          if assigned_options = instance_variable_get("@#{name}")
            options.merge(assigned_options)
          end
        else
          options
        end
      end
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}_assigned", true)
        instance_variable_set("@#{name}", value)
      end
    end

    attr_accessor :command, :exit_code, :output

    def initialize(attributes)
      @exit_code = 0
      @output = ''
      attributes.each { |k,v| send("#{k}=", v) }
    end

    def success?
      exit_code == 0
    end

    attr_with_default(:print_before) do
      "Executing: #{command}"
    end

    attr_with_default(:print_after) do
      # Show all output if it wasn't shown before and the command fails.
      "\n#{output}\n\n" if Kicker.silent? && !success?
    end

    # TODO default titles??

    attr_with_default(:notify_before) do
      { :title => "Kicker: Executing", :message => command } unless Kicker.silent?
    end

    attr_with_default(:notify_after)  do
      message = Kicker.silent? ? "" : output
      if success?
        { :title => "Kicker: Success", :message => message }
      else
        { :title => "Kicker: Failed (#{exit_code})", :message => message }
      end
    end
  end
end
