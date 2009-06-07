$LOAD_PATH << 'lib'
require 'yaml'
require 'activerecord'

require 'jabber_ticker/abstract_loader'
require 'jabber_ticker/ticker'
require 'jabber_ticker/ticker_list_loader'
require 'jabber_ticker/ticker_loader'
require 'jabber_ticker/ticker_bot'
require 'jabber_ticker/subscriber'
require 'jabber_ticker/ticker_line'
require 'jabber_ticker/subscription'
require 'jabber_ticker/score'

LOG = Logger.new('log/development.log')
LOG.level = Logger::DEBUG
# ActiveRecord required ActiveSupport, and this one changes the formatter to SimpleFormatter (which we don't want)
LOG.formatter = Logger::Formatter.new

cfg = YAML.load_file('config/em_ticker.yml')
ActiveRecord::Base.establish_connection(cfg[:db])
Thread.abort_on_exception = true
TickerBot.new(cfg[:bot], TickerListLoader.new(cfg[:ticker][:url])).connect
