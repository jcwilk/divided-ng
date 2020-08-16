class MovesGenerator
  include Callable

  attr_accessor :player, :others

  delegate :floor, to: :player

  def initialize(player, participants:)
    self.player = player
    self.others = participants - [player]
  end

  def call
    surrounding_moves
  end

  private

  def surrounding_moves
    permutations = ((player.x - 3)..(player.x + 3)).to_a.product ((player.y - 3)..(player.y + 3)).to_a

    permutations.
      map { |x, y| Coord.new(x, y) }.
      select { |coord| xy_open?(coord) }.
      map { |coord| coord_to_action(coord) }
  end

  def coord_to_action(coord)
    if coord == player.coord
      MoveGenerator::Wait.call(player, coord)
    elsif enemy_adjacent?(coord)
      MoveGenerator::Attack.call(player, coord)
    else
      MoveGenerator::Run.call(player, coord)
    end
  end

  def enemy_adjacent?(coord)
    others.any? { |o| (o.x - coord.x).abs <= 1 && (o.y - coord.y).abs <= 1 }
  end

  def xy_open?(coord)
    floor.open?(coord) && others.none? { |o| o.coord == coord }
  end
end
