class Make < ActiveRecord::Base
  has_many :cars
  has_and_belongs_to_many :workshops

  validates_presence_of :name

  class << self
    def [](name)
      raise ArgumentError if name.blank?
      find_by_name!(name.to_s)
    end
  end
end
