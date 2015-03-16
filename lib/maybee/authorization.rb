module Maybee

  class Authorization
    attr_reader :access, :subject_classes, :conditionals, :allow_nil
    
    def initialize(access, subject_classes, options)
      raise ArgumentError, "Access name must be symbol" unless access.is_a?(Symbol)
      @access = access
      #raise ArgumentError, "Subject classes must be an array" unless subject_classes.is_a?(Array)
      @subject_classes = subject_classes.empty? ? nil : subject_classes
      options.assert_valid_keys(:if, :unless, :if_subject, :unless_subject, :allow_nil)
      @allow_nil = options.delete(:allow_nil)
      @conditionals = options.empty? ? nil : options      
    end
    
    def granted?(object, subject)
      return false if !@allow_nil && @subject_classes && @subject_classes.none? { |klass| subject.is_a?(klass) }
      return true unless @conditionals
      return true if @conditionals.all? do |clause, cond|
        next(false) if subject.nil? && !@allow_nil
        if :if_subject == clause || :unless_subject == clause
          receiver, argument = subject, object
        else
          receiver, argument = object, subject
        end
        result = if cond.is_a?(Proc)
          if cond.arity == 1
            receiver.instance_exec(argument, &cond)
          else
            receiver.instance_exec(&cond)
          end
        else
          receiver.public_send(cond)
        end
        (:if_subject == clause || :if == clause) ? result : !result
      end
      false
    end
  end
  
end
