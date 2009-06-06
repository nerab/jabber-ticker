class Subscriber < ActiveRecord::Base
  has_many :subscriptions, :dependent => :destroy
  has_many :tickers, :through => :subscriptions, :dependent => :destroy
  
  validates_inclusion_of :status, :in => ['normal', 'wichtig']  
  
  def to_s
    "#{jid} (#{status})"
  end
end
