# This is a wrapper around a RoomParticipant
# It is created when a RoomParticipant joins a round
# It is only tracked by Round
# It holds a snapshot of the RoomParticipant data at that round
# It holds the move made to reach this round
# It holds the moves available to reach the next round

class RoundParticipant
  delegate :user_uuid, to: :room_participant

  def initialize(room_participant)
    self.room_participant = room_participant
  end

  private

  attr_accessor :room_participant
end
