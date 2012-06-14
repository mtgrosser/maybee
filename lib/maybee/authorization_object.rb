module Maybee

  module AuthorizationObject
  
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
      def allows(*accesses)
        options = accesses.extract_options!
        append = options.delete(:append)
        raise ArgumentError, "No accesses given in #{name}" if accesses.empty?
        authorizations = accesses.inject({}) { |hsh, access| hsh[access] = [Authorization.new(access, options)]; hsh }
        self.authorizations = authorizations.merge(authorizations) { |access, parent_auths, new_auths| append ? parent_auths + new_auths : new_auths }
      end
    end
    
    def allow?(access, user = authorization_user)
      authorizations = self.class.authorizations[access] or return(false)
      authorizations.any? { |authorization| authorization.granted?(self, user) }
    end
    
    def authorized_to?(access)
      return true if allow?(access)
      defaults = ([ActiveRecord::Base] + self.class.lookup_ancestors).map do |klass|
        :"#{self.class.i18n_scope}.authorizations.#{klass.model_name.i18n_key}.#{access}"
      end
      key = defaults.shift
      errors.add(:base, :not_authorized, :access => I18n.translate(key, :default => defaults))
    end
    
    #def with_authorization_to(access, object = self)
    #  if authorization_user && authorization_user.may?(access, object)
    #    yield
    #  else
    #    false
    #  end
    #end
    
  end
  
end
