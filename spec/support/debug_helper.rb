module DebugHelper
  def self.short_display(obj)
    if [Class,Module].include?(obj.class)
      obj.to_s
    else
      "#{obj.class}:#{obj.object_id}"
    end
  end

  def pry_around(obj, method_name)
    count = 0
    allow(obj).to receive(method_name).and_wrap_original do |method, *args|
      method.call(*args).tap do |ret|
        puts caller.reverse.join("\n")
        puts "^inverse stack - #{DebugHelper.short_display(obj)}.#{method_name} ##{ count += 1 }"
        binding.pry
      end
    end
  end

  def pry_around_any(klass, method_name)
    count = 0
    allow_any_instance_of(klass).to receive(method_name).and_wrap_original do |method, *args|
      method.call(*args).tap do |ret|
        puts caller.reverse.join("\n")
        puts "^inverse stack - #{klass}##{method_name} ##{ count += 1 }"
        binding.pry
      end
    end
  end
end
