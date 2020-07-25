class AttackGenerator
  def self.call(coord)
    Move.new(
      x: coord.x,
      y: coord.y,
      action: "attack"
    )
  end
end
