class MoveGenerator
  class Wait < MoveGenerator
    def self.call(coord)
      Move.new(
        x: coord.x,
        y: coord.y,
        action: Move::IDLE_ACTION
      )
    end
  end
end
