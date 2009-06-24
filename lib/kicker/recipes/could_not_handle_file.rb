class Kicker
  self.callback = lambda do |kicker, files|
    kicker.log("Could not handle: #{files.join(', ')}")
  end
end