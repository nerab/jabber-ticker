require 'hpricot'
require 'iconv'
require 'open-uri'
require 'date'

#
# Reads list of tickers and write them to the DB
#
class TickerListLoader < AbstractLoader
	UPDATE_LIMIT = 30

  def initialize(url)
    @url = url
    refresh!
	end

  def update_limit
    UPDATE_LIMIT
  end

  def refresh!
    return if too_early_for_reload # skip if called too early

		doc = Hpricot.parse(Iconv.iconv('UTF-8//IGNORE', 'ISO-8859-1', open(@url).read).join)
    doc.search("//ul[@id='wstickerlist']/li").each{|tickerElem|
      date = DateTime.strptime(tickerElem.search("div/span']")[1].to_s, "%d.%m.%Y | %H:%M Uhr") # TODO Is the search argument correct? Shouldn't it rather be "div/span" instead of "div/span']"?
      parties = tickerElem.search('div/strong').inner_text
      link_elem = tickerElem.search("p/a[@class='tickertxt']")

      if link_elem.size > 0
        link = link_elem[0][:href] + '&showall=1&positioned=1'

        # use tid parameter of URL as our ticker identifier
        # e.g. http://sport.ard.de/sp/layout/php/ticker/index.phtml?tid=1317
        tid = link_elem[0][:href].match(/.*\?tid=(\d*)/)[1]

        begin
          t = Ticker.find_by_tid(tid)

          if (t != nil)
            LOG.debug("Ticker #{t.tid} loaded")
          else
            t = Ticker.create!(:tid => tid, :date => date, :parties => parties, :url => link)
            LOG.debug("Ticker #{t.tid} created")
          end
        rescue
          LOG.error($!)
        end
      end
		}
  end
end
