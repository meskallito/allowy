module Allowy
  # This module provides the interface for implementing the access control actions.
  # In order to use it, mix it into a plain Ruby class and define methods ending with `?`.
  # For example:
  #
  #   @example
  #   class PageAccess
  #     include Allowy::AccessControl
  #
  #     def view?(page)
  #       page and page.wiki? and context.user_signed_in?
  #     end
  #   end
  #
  # And then you can check the permissions from a controller:
  #
  #   @example
  #   def show
  #     @page = Page.find params[:id]
  #     authorize! :view, @page
  #   end
  #
  #
  # You can also check the permissions outside of the controller, but you need an object that
  # includes `Allowy::Context` class:
  #
  #   @example
  #   class CucumberContext
  #     include Allowy::Context
  #     attr_accessor :current_user
  #
  #     def initialize(user)
  #       @current_user = user
  #     end
  #   end
  #
  #   CucumberContext.new(that_user).can?(:create, Blog)
  #   CucumberContext.new(that_user).should be_able_to :create, Blog
  #
  module AccessControl
    extend ActiveSupport::Concern
    included do
      attr_reader :context
    end

    def initialize(ctx)
      @context = ctx
    end

    def can?(action, *args)
      m = "#{action}?"
      raise UndefinedAction.new("The #{self.class.name} needs to have #{m} method. Please define it.") unless self.respond_to? m
      send(m, *args)
    end

    def cannot?(*args)
      not can?(*args)
    end

    def authorize!(*args)
      raise AccessDenied.new("Not authorized", args.first, args[1]) unless can?(*args)
    end
  end

end
