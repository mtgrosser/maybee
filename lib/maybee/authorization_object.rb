module Maybee

  module AuthorizationObject
  
    extend ActiveSupport::Concern
    
    included do
      class_attribute :authorizations
      self.authorizations = {}
      attr_accessor :authorization_subject
      if include?(ActiveRecord::Callbacks)
        before_create { wrap_callback_result_with_terminator(authorize?(:create)) }
        before_update { wrap_callback_result_with_terminator(authorize?(:update)) }
        before_destroy { wrap_callback_result_with_terminator(authorize?(:destroy)) }
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
      
      def allows_crud(options = {})
        allows_to :create, :update, :destroy, options.reverse_merge(allow_nil: true)
      end
    end
    
    def allow?(access, subject = authorization_subject)
      authorizations = self.class.authorizations[access] or return(false)
      authorizations.any? { |authorization| authorization.granted?(self, subject) }
    end
    
    def authorize?(access, subject = authorization_subject)
      errors.clear
      return true if allow?(access, subject)
      defaults = (self.class.lookup_ancestors + [ActiveRecord::Base]).map do |klass|
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
    
    private
    
    def wrap_callback_result_with_terminator(result)
      false == result ? throw(:abort) : result
    end
    
  end
  
end
