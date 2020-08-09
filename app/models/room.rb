class Room < MemoryModel
  property :floor, required: true, default: -> { Floor.new }
  property :participants, required: true, default: -> { [] }

  private :floor, :floor=

  delegate :current_round, to: :round_sequence

  def initialize(**)
    super
    self.round_sequence = RoundSequence.new(room_uuid: self.uuid)
  end

  def advance
    round_sequence.advance(room_participants: participants)
  end

  def join(user)
    RoomParticipant.new(user, floor: floor, room_uuid: uuid).tap do |participant|
      participants << participant

      if participants.size == 1
        advance
      end
    end
  end

  def choose_move(move_uuid:, user_uuid:)
    raise "user not participating in room!" if participants.none? { |rp| rp.user_uuid == user_uuid }

    move_selection = MoveSelection.new(move_uuid: move_uuid, user_uuid: user_uuid)
    round_sequence.add_selection(move_selection, room_participants: participants)
  end

  private

  attr_accessor :round_sequence
end
