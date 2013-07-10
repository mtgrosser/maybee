require 'active_record'
require 'active_support'
require 'active_support/concern'

require 'i18n'

require 'maybee/version'
require 'maybee/authorization'
require 'maybee/authorization_object'
require 'maybee/authorization_subject'
require 'maybee/i18n'

module Maybee
  extend ActiveSupport::Concern
  
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
