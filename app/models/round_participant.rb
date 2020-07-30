# This is a wrapper around a RoomParticipant
# It is created when a RoomParticipant joins a round
# It is only tracked by Round
# It holds a snapshot of the RoomParticipant data at that round
# It holds the move made to reach this round
# It holds the moves available to reach the next round

class RoundParticipant < MemoryModel
  property :move, required: true
  property :room_participant, required: true

  delegate :user_uuid, :floor, to: :room_participant
  delegate :x, :y, :coord, to: :move

  def initialize(room_participant, **args)
    super(**args, room_participant: room_participant)
  end

  def moves
    raise "moves not yet assigned!" if !finalized?

    moves_relation.all
  end

  def move_by_uuid(uuid)
    moves_relation.by_uuid(uuid)
  end

  def move_by_action(action)
    moves_relation.by(:action, action)
  end

  def moves=(moves)
    raise "moves assigned when moves already exist!" if finalized?
    raise "empty moves assigned!" if moves.nil?

    @moves_relation = HasMany.new(Move, members: moves, indices: [:action])
  end

  def finalized?
    !!moves_relation
  end

  private

  attr_reader :moves_relation
end
