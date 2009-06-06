si = Ticker.create!(:tid => 1319, :parties => "Spanien - Italien", :date => DateTime.strptime("23.06.2008 12:30", "%d.%m.%Y %H:%M"))
dt = Ticker.create!(:tid => 1320, :parties => "Deutschland - Türkei", :date => DateTime.strptime("25.06.2008 12:30", "%d.%m.%Y %H:%M"))

su = Subscriber.create!(:jid => "steffen@familie-uhlig.net")

Subscription.create!(:subscriber => su, :ticker => si)
Subscription.create!(:subscriber => su, :ticker => dt)

Subscription.find(:all).each{|s| puts "#{s.subscriber} subscribed to #{s.ticker}"}

Ticker.create!(:tid => 6666, :parties => "USA - Iran", :date => DateTime.now)
Ticker.create!(:tid => 9999, :parties => "Springfield - Shelbyville", :date => DateTime.now.advance(:minutes => 180))
