module Maybee

  module AuthorizationSubject
    
    def may?(access, object)
      object.allow?(access, self)
    end
    
    def authorized_to?(access, object)
      object.authorize?(access, self)
    end

  end
  
end
