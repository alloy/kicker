require File.expand_path('../test_helper', __FILE__)

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
    @chain = Kicker::CallbackChain.new
    @result = []
  end
  
  it "should call the callbacks from first to last" do
    @chain.append_callback lambda { @result << 1 }
    @chain.append_callback lambda { @result << 2 }
    @chain.run([])
    @result.should == [1, 2]
  end
  
  it "should pass the files array given to run to the first callback and pass the result array of that call to the next callback and so on" do
    @chain.append_callback lambda { |files|
      @result.concat(files)
      %w{ /file/3 /file/4 }
    }
    
    @chain.append_callback lambda { |files|
      @result.concat(files)
      []
    }
    
    @chain.run(%w{ /file/1 /file/2 })
    @result.should == %w{ /file/1 /file/2 /file/3 /file/4 }
  end
  
  it "should halt the callback chain once an empty array is returned from a callback" do
    @chain.append_callback lambda { @result << 1; [] }
    @chain.append_callback lambda { @result << 2 }
    @chain.run(%w{ /file/1 /file/2 })
    @result.should == [1]
  end
  
  it "should halt the callback chain if not an Array instance is returned from a callback" do
    [nil, false, ''].each do |object|
      @chain.clear
      @result.clear
      
      @chain.append_callback lambda { @result << 1; object }
      @chain.append_callback lambda { @result << 2 }
      @chain.run(%w{ /file/1 /file/2 })
      @result.should == [1]
    end
  end
end