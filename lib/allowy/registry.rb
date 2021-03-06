module Allowy
  class Registry
    def initialize(ctx)
      @context = ctx
      @registry = {}
    end

    def access_control_for!(subject)
      ac = access_control_for subject
      raise UndefinedAccessControl.new("Please define Access Control class for #{subject.inspect}") unless ac
      ac
    end

    def access_control_for(subject)
      return unless subject
      # Try subject as an object
      clazz = class_for "#{subject.class.name}Access"

      # Try subject as a class
      clazz = class_for "#{subject.name}Access" if !clazz && [Class, ActiveRecord::Associations::CollectionProxy].any? { |klass| subject.is_a?(klass) }

      # Try subject as a array
      clazz = class_for "#{subject[0].class.name}Access" if !clazz && subject.is_a?(Array)

      return unless clazz # No luck this time
      # create a new instance or return existing
      @registry[clazz] ||= clazz.new(@context)
    end

    def class_for(name)
      name.constantize rescue nil #TODO: Handle just the NameError
    end

  end
end
