# frozen_string_literal: true

class DeferredCall
  QUEUE = Queue.new

  mattr_accessor :disabled

  def self.enqueue(*args)
    raise "Started looping out of a reactor!" if disabled

    QUEUE.push(new(*args))
  end

  def self.start_looping
    if Async::Task.current?
      loop_async
    else
      self.disabled = true
    end
  end

  def self.loop_async
    Async do |task|
      task.sleep 0.001

      drain_all

      loop_async
    end
  end

  def self.drain_all
    while !QUEUE.empty? do
      QUEUE.pop.call
    end
  end

  attr_accessor :target, :method_name, :args

  def initialize(target, method_name, *args)
    self.target = target
    self.method_name = method_name
    self.args = args
  end

  def call
    target.send(method_name, *args)
  end
end
