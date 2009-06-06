$LOAD_PATH << 'lib'
require "activerecord"

ActiveRecord::Base.establish_connection(YAML.load_file("config/em_ticker.yml")[:db])

ActiveRecord::Schema.define do
  create_table :tickers do |t|
    t.column :tid, :integer
    t.column :date, :datetime
    t.column :parties, :string
    t.column :score_id, :string
    t.column :url, :string
    t.timestamps
  end
  
  add_index :tickers, :tid, :unique
  add_index :tickers, [:id, :score_id], :unique

  create_table :ticker_lines do |t|
    t.column :date, :string
    t.column :text, :string
    t.column :order, :integer, :default => 0
    t.column :severity, :integer, :default => 0
    t.column :ticker_id, :integer
    t.timestamps
  end
  
  add_index :ticker_lines, [:date, :text], :unique

  create_table :scores do |t|
    t.column :ticker_id, :integer
    t.column :left, :integer
    t.column :right, :integer
    t.timestamps
  end

  add_index :scores, [:ticker_id, :left, :right], :unique
  
  create_table :subscribers do |t|
    t.column :jid, :string
    t.column :status, :string, :default => 'normal'
    t.timestamps
  end

  create_table :subscriptions do |t|
    t.column :subscriber_id, :integer
    t.column :ticker_id, :integer
    t.timestamps
  end
  
  add_index :subscriptions, [:subscriber_id, :ticker_id], :unique
end

#si = Ticker.create!(:tid => 1319, :parties => "Spanien - Italien", :date => DateTime.strptime("23.06.2008 12:30", "%d.%m.%Y %H:%M"))
#dt = Ticker.create!(:tid => 1320, :parties => "Deutschland - Türkei", :date => DateTime.strptime("25.06.2008 12:30", "%d.%m.%Y %H:%M"))
#
#su = Subscriber.create!(:jid => "steffen@familie-uhlig.net")
#
#Subscription.create!(:subscriber => su, :ticker => si)
#Subscription.create!(:subscriber => su, :ticker => dt)
#
#Subscription.find(:all).each{|s| puts "#{s.subscriber} subscribed to #{s.ticker}"}
#
#si.ticker_lines << TickerLine.create!(:text => "huhu")
#si.save!
#
#TickerLine.find(:all).each{|tl| puts "#{tl}\n"}
