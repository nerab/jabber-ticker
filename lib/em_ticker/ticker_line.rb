require 'digest/md5'

class TickerLine < ActiveRecord::Base
  belongs_to :ticker

	def hash
		Digest::MD5.hexdigest("jabber-ticker##{to_s}")
	end

	def known?(tl)
	  TickerLine.find_by_hash(tl.hash).empty?
	end

	def to_s
		"#{date}: #{text}"
	end
end
