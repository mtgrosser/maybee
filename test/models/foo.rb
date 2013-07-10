class Foo < ActiveRecord::Base
  
  acts_as_authorization_object
  allows_crud
    
end