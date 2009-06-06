$LOAD_PATH << 'lib'
require 'yaml'
require 'activerecord'

require 'em_ticker/abstract_loader'
require 'em_ticker/ticker'
require 'em_ticker/ticker_list_loader'
require 'em_ticker/ticker_loader'
require 'em_ticker/ticker_bot'
require 'em_ticker/subscriber'
require 'em_ticker/ticker_line'
require 'em_ticker/subscription'
require 'em_ticker/score'

LOG = Logger.new('log/development.log')
LOG.level = Logger::DEBUG
# ActiveRecord required ActiveSupport, and this one changes the formatter to SimpleFormatter (which we don't want)
LOG.formatter = Logger::Formatter.new

cfg = YAML.load_file('config/em_ticker.yml')
ActiveRecord::Base.establish_connection(cfg[:db])
Thread.abort_on_exception = true
TickerBot.new(cfg[:bot], TickerListLoader.new(cfg[:ticker][:url])).connect
