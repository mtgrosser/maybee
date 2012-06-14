module Maybee

  class Authorization
    attr_reader :access, :options
    
    def initialize(access, options)
      raise ArgumentError, "Access name must be symbol" unless access.is_a?(Symbol)
      @access = access
      options.assert_valid_keys(:if, :unless, :if_user, :unless_user)
      @options = options
    end
    
    def granted?(record, user)
      return true if options.empty?
      conditionals = options.dup.extract!(:if, :unless, :if_user, :unless_user)
      return true if conditionals.empty?
      return true if conditionals.all? do |clause, cond|
        if :if_user == clause || :unless_user == clause
          receiver, argument = user, record
        else
          receiver, argument = record, user
        end
        result = cond.is_a?(Proc) ? cond.bind(receiver).call(argument) : receiver.send(cond)
        (:if_user == clause || :if == clause) ? result : !result
      end
      false
    end
  end
  
end
