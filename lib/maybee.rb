require 'active_record'
require 'active_support'
require 'i18n'

require 'maybee/version'
require 'maybee/authorization'
require 'maybee/authorization_object'
require 'maybee/authorization_subject'
require 'maybee/i18n'

module Maybee

  def self.included(base) # :nodoc:
    base.extend ClassMethods
    base.class_attribute :authorizations
    base.authorizations = {}
  end
  
  module ClassMethods
  
    #
    #
    #
    def acts_as_authorization_object
      include AuthorizationObject
      attr_accessor :authorization_subject
      before_create { authorized_to?(:create) }
      before_update { authorized_to?(:update) }
      before_destroy { authorized_to?(:destroy) }
    end
    
    #
    #
    #
    def acts_as_authorization_subject
      include AuthorizationSubject
    end    
  end

end

ActiveRecord::Base.class_eval { include Maybee }

