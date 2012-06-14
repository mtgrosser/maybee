class Driver < ActiveRecord::Base
  acts_as_authorization_subject

  validates_presence_of :name
end
