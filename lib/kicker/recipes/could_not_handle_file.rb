class Kicker
  COULD_NOT_HANDLE_CALLBACK = lambda do |kicker, files|
    kicker.log("Could not handle: #{files.join(', ')}")
  end
  
  self.callback = COULD_NOT_HANDLE_CALLBACK
end