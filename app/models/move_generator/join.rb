class MoveGenerator
  class Join < MoveGenerator
    def self.call(coord)
      Move.new(x: coord.x, y: coord.y, action: "join")
    end
  end
end
