class Workshop < ActiveRecord::Base
  acts_as_authorization_subject
  
  has_and_belongs_to_many :makes
  
  validates_presence_of :name
end
