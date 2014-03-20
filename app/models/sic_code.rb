class SicCode < ActiveRecord::Base
  include FormatterConcern

  attr_accessible :code, :description, :eligible, :public_sector_restricted, :active

  validates_presence_of :code, :description, :state_aid_threshold
  validates_uniqueness_of :code
  validates_inclusion_of :eligible, in: [true, false]
  validates_inclusion_of :public_sector_restricted, in: [true, false]

  default_scope { order(:code) }
  scope :active, -> { where(active: true) }

  format :state_aid_threshold, with: MoneyFormatter.new('EUR')
end
