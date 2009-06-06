class Score < ActiveRecord::Base
  belongs_to :ticker, :dependent => :destroy
  has_one    :ticker, :dependent => :destroy

  validates_numericality_of :left, :right
  validates_inclusion_of :left,  :in => 0..99
  validates_inclusion_of :right, :in => 0..99

  def to_s
		'#{left}:#{right}'
	end
end
