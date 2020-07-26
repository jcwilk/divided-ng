class MoveGenerator
  class Run < MoveGenerator
    def self.call(coord)
      Move.new(x: coord.x, y: coord.y, action: "run")
    end
  end
end
