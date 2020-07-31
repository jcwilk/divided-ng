class Room < MemoryModel
  property :floor, required: true, default: -> { Floor.new }
  property :round_sequence, required: true, default: -> { RoundSequence.new }
  property :participants, required: true, default: -> { [] }

  private :floor, :floor=, :round_sequence, :round_sequence=

  delegate :current_round, to: :round_sequence

  def advance
    round_sequence.advance(room_participants: participants)
  end

  def join(user)
    RoomParticipant.new(user, floor: floor, room_uuid: uuid).tap do |participant|
      participants << participant
    end
  end
end
