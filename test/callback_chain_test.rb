require File.expand_path('../test_helper', __FILE__)

describe "Kicker, concerning its callback chains" do
  before do
    @chains = [:pre_process_chain, :process_chain, :post_process_chain]
  end
  
  it "should return the callback chain instances" do
    @chains.each do |chain|
      Kicker.send(chain).should.be.instance_of Kicker::CallbackChain
    end
  end
  
  it "should be accessible by an instance" do
    kicker = Kicker.new({})
    
    @chains.each do |chain|
      kicker.send(chain).should.be Kicker.send(chain)
    end
  end
  
  it "should provide a shortcut method which appends a callback to the pre-process chain" do
    Kicker.pre_process_chain.expects(:append_callback).with do |callback|
      callback.call == :from_callback
    end
    
    Kicker.pre_process_callback = lambda { :from_callback }
  end
  
  it "should provide a shortcut method which appends a callback to the process chain" do
    Kicker.process_chain.expects(:append_callback).with do |callback|
      callback.call == :from_callback
    end
    
    Kicker.process_callback = lambda { :from_callback }
  end
  
  it "should provide a shortcut method which prepends a callback to the post-process chain" do
    Kicker.post_process_chain.expects(:prepend_callback).with do |callback|
      callback.call == :from_callback
    end
    
    Kicker.post_process_callback = lambda { :from_callback }
  end
end

describe "Kicker::CallbackChain" do
  it "should be a subclass of Array" do
    Kicker::CallbackChain.superclass.should.be Array
  end
end

describe "An instance of Kicker::CallbackChain, concerning it's API" do
  before do
    @chain = Kicker::CallbackChain.new
    
    @callback1 = lambda {}
    @callback2 = lambda {}
  end
  
  it "should append a callback" do
    @chain << @callback1
    @chain.append_callback(@callback2)
    
    @chain.should == [@callback1, @callback2]
  end
  
  it "should prepend a callback" do
    @chain << @callback1
    @chain.prepend_callback(@callback2)
    
    @chain.should == [@callback2, @callback1]
  end
end

describe "An instance of Kicker::CallbackChain, when running the chain" do
  before do
    @kicker = Kicker.new({})
    
    @chain = Kicker::CallbackChain.new
    @result = []
  end
  
  it "should call the callbacks from first to last" do
    @chain.append_callback lambda { @result << 1 }
    @chain.append_callback lambda { @result << 2 }
    @chain.run(@kicker, [])
    @result.should == [1, 2]
  end
  
  it "should pass in the Kicker instance with each yield" do
    kicker = nil
    @chain.append_callback lambda { |x, _| kicker = x }
    @chain.run(@kicker, [])
    kicker.should.be @kicker
  end
  
  it "should pass the files array given to run to the first callback and pass the result array of that call to the next callback and so on" do
    @chain.append_callback lambda { |_, files|
      @result.concat(files)
      %w{ /file/3 /file/4 }
    }
    
    @chain.append_callback lambda { |_, files|
      @result.concat(files)
      []
    }
    
    @chain.run(@kicker, %w{ /file/1 /file/2 })
    @result.should == %w{ /file/1 /file/2 /file/3 /file/4 }
  end
  
  it "should halt the callback chain once an empty array is returned from a callback" do
    @chain.append_callback lambda { @result << 1; [] }
    @chain.append_callback lambda { @result << 2 }
    @chain.run(@kicker, %w{ /file/1 /file/2 })
    @result.should == [1]
  end
  
  it "should halt the callback chain if not an Array instance is returned from a callback" do
    [nil, false, ''].each do |object|
      @chain.clear
      @result.clear
      
      @chain.append_callback lambda { @result << 1; object }
      @chain.append_callback lambda { @result << 2 }
      @chain.run(@kicker, %w{ /file/1 /file/2 })
      @result.should == [1]
    end
  end
end