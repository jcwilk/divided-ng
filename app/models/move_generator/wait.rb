class MoveGenerator
  class Wait < MoveGenerator
    def self.call(coord)
      Move.new(
        x: coord.x,
        y: coord.y,
        action: "wait"
      )
    end
  end
end
