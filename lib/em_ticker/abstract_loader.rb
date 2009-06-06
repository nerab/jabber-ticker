class AbstractLoader
  def too_early_for_reload
		now = Time.new
		if @last_refresh.nil?		
			diff = 999999
		else
			diff = now.to_i - @last_refresh.to_i
		end
				
		if diff <= update_limit
			true
		else
			@last_refresh = now
      false
		end
  end
  
  def update_limit
    30
  end
end