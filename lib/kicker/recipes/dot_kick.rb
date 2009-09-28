module ReloadDotKick #:nodoc
  class << self
    def save_state
      @features_before_dot_kick = $LOADED_FEATURES.dup
      @chains_before_dot_kick = Kicker.full_chain.map { |c| c.dup }
    end
    
    def call(files)
      if files.delete('.kick')
        reset!
        load '.kick'
      end
    end
    
    def reset!
      remove_loaded_features!
      reset_chains!
    end
    
    def reset_chains!
      Kicker.full_chain = nil
      
      chains = @chains_before_dot_kick.map { |c| c.dup }
      Kicker.pre_process_chain, Kicker.process_chain, Kicker.post_process_chain = *chains
    end
    
    def remove_loaded_features!
      ($LOADED_FEATURES - @features_before_dot_kick).each do |feat|
        $LOADED_FEATURES.delete(feat)
      end
    end
  end
end

process ReloadDotKick