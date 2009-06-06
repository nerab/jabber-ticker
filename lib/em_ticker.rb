$LOAD_PATH << 'lib'
require "yaml"
require "activerecord"

require 'em_ticker/abstract_loader'
require 'em_ticker/ticker'
require 'em_ticker/ticker_list_loader'
require 'em_ticker/ticker_loader'
require 'em_ticker/ticker_bot'
require 'em_ticker/subscriber'
require 'em_ticker/ticker_line'
require 'em_ticker/subscription'
require 'em_ticker/score'

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG

cfg = YAML.load_file('config/em_ticker.yml')
ActiveRecord::Base.establish_connection(cfg[:db])
Thread.abort_on_exception = true
TickerBot.new(cfg[:bot], TickerListLoader.new(cfg[:ticker][:url])).connect

# TODO There are more tickers. Let's scrape them too and make them available.
# TickerBot.new(TickerRegistry.new('http://sport.ard.de/sp/portrait/ticker_termine.jsp')).connect
#
# A DTM Ticker is different
# url = 'http://sport.ard.de/sp/layout/php/sportticker/?event_art=24&ticker=819&event=3287'
# doc = Hpricot.parse(Iconv.iconv('UTF-8//IGNORE', 'ISO-8859-1', open(url).read).join)
# doc.search('//div[@id='tickerMeldungen']/p').each{|line|
#     runde = line.search('span').inner_text
# 	line.search('span').remove
#     puts '-> #{runde}' if !runde.empty?
#     puts line.inner_text
# }
