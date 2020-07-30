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
    raise "moves not yet assigned!" if @moves.nil?

    @moves
  end

  def moves=(moves)
    raise "moves assigned when moves already exist!" if @moves
    raise "empty moves assigned!" if moves.nil?

    @moves = moves
  end

  def finalized?
    !!@moves
  end
end
