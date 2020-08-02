# This orchestrates Rounds leading into other Rounds
# It has a queue for RoomParticipants joining into the next round
# It hands them off to rounds to become RoundParticipants

class RoundSequence < MemoryModel
  def initialize(room_uuid:)
    super()

    @room_uuid = room_uuid

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

    # TODO: build this into a MemoryModel helper
    ActionCable.server.broadcast(
      "/dv/rooms/#{@room_uuid}/current_round",
      **DV::Representers::Round.new(current_round).to_hash
    )
  end

  def add_selection(move_selection, room_participants:)
    raise "user already made selection!" if move_selections.any? { |ms| ms.user_uuid == move_selection.user_uuid }

    move_selections << move_selection

    if (room_participants.map(&:user_uuid) - move_selections.map(&:user_uuid)).empty?
      advance(room_participants: room_participants)
    end
  end

  private

  attr_accessor :move_selections, :round_uuids

  def reset_move_selections
    self.move_selections = []
  end
end
