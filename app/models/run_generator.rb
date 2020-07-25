class RunGenerator
  def self.call(coord)
    Move.new(x: coord.x, y: coord.y, action: "run")
  end
end
