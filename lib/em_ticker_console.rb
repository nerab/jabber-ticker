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

ActiveRecord::Base.establish_connection(YAML.load_file('config/em_ticker.yml')[:db])
