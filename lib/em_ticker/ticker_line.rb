require 'digest/md5'

class TickerLine < ActiveRecord::Base
  belongs_to :ticker

	def hash
		Digest::MD5.hexdigest("2008-06-19_23.47##{to_s}")
	end

	def known?(tl)
	  TickerLine.find_by_hash(tl.hash).empty?
	end
  
	def to_s
		"#{date}: #{text}"
	end
end
