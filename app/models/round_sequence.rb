# This orchestrates Rounds leading into other Rounds
# It has a queue for RoomParticipants joining into the next round
# It hands them off to rounds to become RoundParticipants

class RoundSequence < MemoryModel
  def initialize
    super

    self.rounds = [Round.start]

    reset_move_selections
  end

  def current_round
    rounds.last
  end

  def advance(room_participants:)
    rounds << current_round.advance(
      room_participants: room_participants,
      move_selections: move_selections
    )

    reset_move_selections
  end

  private

  attr_accessor :move_selections, :rounds

  def reset_move_selections
    self.move_selections = []
  end
end
