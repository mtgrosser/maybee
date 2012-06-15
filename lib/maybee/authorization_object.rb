module Maybee

  module AuthorizationObject
  
    def self.included(base)
      base.extend ClassMethods
      base.class_attribute :authorizations
      base.authorizations = {}
      base.class_eval do
        attr_accessor :authorization_subject
        before_create { authorize?(:create) }
        before_update { authorize?(:update) }
        before_destroy { authorize?(:destroy) }
      end
    end
  
    module ClassMethods
      def allows(*args)
        options = args.extract_options!
        accesses = Array(options.delete(:to))
        raise ArgumentError, "No accesses given" if accesses.empty?
        exclusive = options.delete(:exclusive)
        subject_classes = args.map { |name| name.is_a?(Symbol) ? name.to_s.classify.constantize : name.constantize }
        additional_authorizations = accesses.inject({}) { |hsh, access| hsh[access] = [Authorization.new(access, subject_classes, options)]; hsh }
        self.authorizations = authorizations.merge(additional_authorizations) { |access, previous_auths, new_auths| exclusive ? new_auths : previous_auths + new_auths }
      end
      
      def allows_to(*accesses)
        options = accesses.extract_options!
        allows options.merge(:to => accesses)
      end
    end
    
    def allow?(access, subject = authorization_subject)
      authorizations = self.class.authorizations[access] or return(false)
      authorizations.any? { |authorization| authorization.granted?(self, subject) }
    end
    
    def authorize?(access)
      errors.clear
      return true if allow?(access)
      defaults = ([ActiveRecord::Base] + self.class.lookup_ancestors).map do |klass|
        :"#{self.class.i18n_scope}.authorizations.#{klass.model_name.i18n_key}.#{access}"
      end
      key = defaults.shift
      errors.add(:base, :not_authorized, :access => I18n.translate(key, :default => defaults))
      false
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
