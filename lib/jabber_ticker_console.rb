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

ActiveRecord::Base.establish_connection(YAML.load_file('config/jabber_ticker.yml')[:db])
