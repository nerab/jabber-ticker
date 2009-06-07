$LOAD_PATH << 'lib'
require "activerecord"

ActiveRecord::Base.establish_connection(YAML.load_file("config/jabber_ticker.yml")[:db])
ActiveRecord::Schema.define do
  drop_table :tickers
end
ActiveRecord::Schema.define do
  drop_table :subscribers
end
ActiveRecord::Schema.define do
  drop_table :subscriptions
end
ActiveRecord::Schema.define do
  drop_table :ticker_lines
end
ActiveRecord::Schema.define do
  drop_table :scores
end
