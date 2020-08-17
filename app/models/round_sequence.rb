# This orchestrates Rounds leading into other Rounds
# It has a queue for RoomParticipants joining into the next round
# It hands them off to rounds to become RoundParticipants

class RoundSequence < MemoryModel
  def initialize(room_uuid:)
    super()

    @room_uuid = room_uuid

    self.round_uuids = [Round.start.uuid]

    reset_buffers
  end

  def current_round
    Round.by_uuid(round_uuids.last)
  end

  def advance(room_participants:)
    round_uuids << RoundResolver.call(
      room_participants: room_participants,
      move_selections: move_selections,
      round: current_round
    ).uuid

    reset_buffers

    broadcast_current_round
  end

  def add_joiner(new_room_participant, room_participants:)
    raise "already joined!" if joiners.any? { |p| p.user_uuid == user.uuid }

    joiners << new_room_participant

    advance_if_complete(room_participants)
  end

  def add_selection(move_selection, room_participants:)
    raise "user already made selection!" if move_selections.any? { |ms| ms.user_uuid == move_selection.user_uuid }

    move_selections << move_selection

    advance_if_complete(room_participants)
  end

  def advance_if_complete(room_participants)
    advance(room_participants: room_participants) if full_round?(room_participants)
  end

  private

  attr_accessor :joiners, :move_selections, :round_uuids

  def reset_buffers
    self.move_selections = []
    self.joiners = []
  end

  def full_round?(room_participants)
    (room_participants.map(&:user_uuid) - move_selections.map(&:user_uuid) - joiners.map(&:user_uuid)).empty?
  end

  def broadcast_current_round
    # TODO: build this into a MemoryModel helper?
    ActionCable.server.broadcast(
      current_round_key,
      **current_round.dv_hash
    )
  end

  def current_round_key
    DVChannel.current_round_key(room_uuid: @room_uuid)
  end
end
