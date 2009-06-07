class Subscription < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :ticker
end
