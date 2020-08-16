module Callable
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def call(*args)
      new(*args).call
    end
  end
end
