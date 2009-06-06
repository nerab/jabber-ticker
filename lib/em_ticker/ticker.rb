class Ticker < ActiveRecord::Base
  has_many   :subscriptions, :dependent => :destroy
  has_many   :subscribers, :through => :subscriptions, :dependent => :destroy  
  has_many   :ticker_lines, :dependent => :destroy
  belongs_to :score, :dependent => :destroy
  has_one    :score, :dependent => :destroy
  
  validates_presence_of :tid, :date, :url
  validates_uniqueness_of :tid
  
  #
  # returns true if game is running at time t (defaults to DateTime.now)
  #
  def running?(t = DateTime.now)
    Range.new(date, date.advance(:minutes => 180)).include?(t)
  end
  
  def to_s
    "#{tid}: #{parties} am #{date.strftime('%d.%m.%Y %H:%M')}"
  end
end
