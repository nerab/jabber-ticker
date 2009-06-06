require 'hpricot'
require 'iconv'
require 'open-uri'
require 'date'

#
# grab ticker source, write to db and update subscribers about new lines
#
class TickerLoader < AbstractLoader
	UPDATE_LIMIT = 10

	def initialize(ticker)
	  @ticker = ticker
    @subscribers = []
	end

  def update_limit
    UPDATE_LIMIT
  end

	def refresh!
    return if too_early_for_reload # skip if called too early
    LOG.debug('refreshing ticker #{@ticker}')

		doc = Hpricot.parse(Iconv.iconv('UTF-8//IGNORE', 'ISO-8859-1', open(@ticker.url).read).join)
		doc.search('//div[@id='ardTickerScroll']/p').each{|line|
		  ts = line.search('span').inner_text
			line.search('span').remove
			line.at('br').swap(' ') if line.at('br')
			text = line.inner_text.strip

      tl = TickerLine.find_by_date_and_text(ts, text)

      if tl != nil # line is known
        LOG.debug 'found existing TickerLine: #{tl.id}'
      else
        tl = TickerLine.create!(:date => ts, :text => text)
				LOG.debug 'created new TickerLine: #{tl}'
        tl.severity = line.search("img[@class='ardTTEreignisImg']").size
        @ticker.ticker_lines << tl
				@subscribers.each{|s| s.on_ticker_line(tl)}

				# score
				left = doc.search("//img[@class='zahll']")[0][:alt].to_i
				right = doc.search("//img[@class='zahlr']")[0][:alt].to_i

				LOG.debug 'Known score was #{@ticker.score}. Web site says #{left}:#{right}'

        # TODO Here is something wrong. This code fails.
        begin
	        if @ticker.score.nil? # this one must be new
			        LOG.debug 'No score found in db.'
	            @ticker.score = Score.create!(:ticker => @ticker, :left => left, :right => right)
	            LOG.debug 'New score is #{score}.'
	            @subscribers.each{|s| s.on_score(@ticker.score)}
	        else # old, maybe changed?
	          LOG.debug 'Existing score in db is #{@ticker.score}.'
	          if @ticker.score.left != left || @ticker.score.right != right
	            @ticker.score = Score.create!(:ticker => @ticker, :left => left, :right => right)
	            LOG.debug 'New score is #{@ticker.score}. Now notifying subscribers'
		          @subscribers.each{|s| s.on_score(@ticker.score)}
	            LOG.debug 'Done notifying subscribers'
		        end
	        end
        rescue
          LOG.error('## Error in score construction: #{$!}')
				end
      end
		}
	end

	def subscribe(subscriber)
		@subscribers << subscriber
	end

	def unsubscribe(subscriber)
		@subscribers.delete(subscriber)
	end

	def subscribed?(subscriber)
	  @subscribers.include?(subscriber)
	end
end
