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
    base.class_attribute :authorizations
    base.authorizations = {}
    base.extend ClassMethods
  end
  
  module ClassMethods
  
    #
    #
    #
    def acts_as_authorization_object
      include AuthorizationObject
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

