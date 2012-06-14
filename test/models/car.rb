class Car < ActiveRecord::Base
  acts_as_authorization_object
  
  belongs_to :make
  
  validates_presence_of :model, :make, :minimum_driver_level

  attr_accessor :broken, :repairable

  # Just grant the authorization without any requirement for the subject
  allows_to :create, :update, :allow_nil => true
    
  # Do not require a class for the subject
  # driver.may?(:start, car) => true
  # workshop.may?(:start, car) => true
  allows :to => :start

  # Require the subject to be of the given class and fulfill all conditions
  # driver.may?(:drive, car) => true
  # workshop.may?(:drive, car) => false
  allows :drivers, :to => :drive, :if_subject => lambda { |car| level >= car.minimum_driver_level }
  
  # Multiple subject classes may be given. Strings will be treated as class names.
  allows :drivers, '::Workshop', :to => :wash
  
  # Combine conditions for subject and object, both must be fulfilled  
  allows :workshops, :to => :repair, :if => :broken?, :if_subject => lambda { |car| makes.include?(car.make) }

  # If the subject is a driver, it may always destroy the car
  # if it's a workshop, the car must not be repairable
  # anything else (including nil) is forbidden to destroy the car
  allows :drivers, :to => :destroy
  allows :workshops, :to => :destroy, :unless => :repairable?
    
  def broken?
    broken
  end
  
  def repairable?
    broken? && @repairable
  end
  
  def repair!
    return false unless authorize?(:repair)
    self.broken = false
  end
  

end
