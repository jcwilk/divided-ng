class Participant < Hashie::Dash
  property :player, required: true
  property :round,  required: true

  delegate :uuid, to: :player
  delegate :moves, :stationary_move, to: :move_generator

  def choose_move(id)
    move_by_id(id).tap do |move|
      round.add_move(player: player, move: move) if move
    end
  end

  def move_by_id(id)
    moves.find {|m| m.id == id }
  end

  def round_id
    round.index
  end

  def attacked_recently?
    round.attacked_in_last_x_moves?(player,2)
  end

  private

  def move_generator
    MoveGenerator.new(participant: self, round: round)
  end

  def init_pos
    round.init_pos_map[player]
  end

  def near_other_players?(x,y)
    (round.init_pos_map.keys - [player]).any? do |p|
      px,py = round.init_pos_map[p]
      [(px-x).abs,(py-y).abs].max <= 1
    end
  end
end
