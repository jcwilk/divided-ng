# This orchestrates Rounds leading into other Rounds
# It has a queue for RoomParticipants joining into the next round
# It hands them off to rounds to become RoundParticipants

class RoundSequence < MemoryModel
  def initialize
    super

    self.round_uuids = [Round.start.uuid]

    reset_move_selections
  end

  def current_round
    Round.by_uuid(round_uuids.last)
  end

  def advance(room_participants:)
    round_uuids << current_round.advance(
      room_participants: room_participants,
      move_selections: move_selections
    ).uuid

    reset_move_selections
  end

  private

  attr_accessor :move_selections, :round_uuids

  def reset_move_selections
    self.move_selections = []
  end
end
