# frozen_string_literal: true

class DeferredCall
  QUEUE = Queue.new

  def self.enqueue(*args)
    QUEUE.push(new(*args))
  end

  def self.drain_all
    while !QUEUE.empty? do
      QUEUE.pop.call
    end
  end

  def self.loop_async
    raise "called outside of a reactor!" if !Async::Task.current?

    Async do |task|
      task.sleep 0.001

      drain_all

      loop_async
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
