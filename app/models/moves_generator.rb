class MovesGenerator
  def self.call(*args)
    new(*args).call
  end

  attr_accessor :player, :others, :floor

  def initialize(player, participants:)
    self.player = player
    self.others = participants - [player]
    self.floor = player.floor
  end

  def call
    [Move.new(x: 0, y: 0, action: "wait")]
  end

  private

  def check_enemy_adjacent(x, y)
    others.any? { |o| (o.x - x).abs <= 1 && (o.y - y).abs <= 1 }
  end

  def check_xy_open(x, y)
    floor.check_xy_open(x, y) && others.none? { |o| o.x == x && o.y == y }
  end
end
