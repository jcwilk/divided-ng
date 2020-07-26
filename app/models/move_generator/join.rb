class MoveGenerator
  class Join < MoveGenerator
    def self.call # TODO: How will this know where to place the player?
      Move.new(x: 0, y: 0, action: "join")
    end
  end
end
