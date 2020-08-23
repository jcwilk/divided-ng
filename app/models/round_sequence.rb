# This orchestrates Rounds leading into other Rounds
# It has a queue for RoomParticipants joining into the next round
# It hands them off to rounds to become RoundParticipants

class RoundSequence < MemoryModel
  def initialize(room_uuid:, room_participants:)
    super()

    @room_uuid = room_uuid

    self.round_uuids = [Round.start.uuid]
    self.room_participants = room_participants

    reset_buffers
  end

  def current_round
    Round.by_uuid(round_uuids.last)
  end

  def advance
    round_uuids << RoundResolver.call(
      room_participants: room_participants,
      move_selections: move_selections,
      round: current_round
    ).uuid

    reset_buffers

    broadcast_current_round

    delayed_advance
  end

  def add_joiner(new_room_participant)
    raise "already joined!" if joiners.any? { |p| p.user_uuid == new_room_participant.uuid }

    joiners << new_room_participant

    advance_if_complete
  end

  def add_selection(move_selection)
    raise "user already made selection!" if move_selections.any? { |ms| ms.user_uuid == move_selection.user_uuid }

    move_selections << move_selection

    advance_if_complete
  end

  def advance_if_complete
    advance if full_round?
  end

  private

  attr_accessor :joiners, :move_selections, :round_uuids, :room_participants

  def delayed_advance
    prior_round = current_round
    Async do |task|
      puts "sleeping..."
      task.sleep 5
      if current_round == prior_round
        puts "advancing!"
        advance
      else
        puts "already advanced..."
      end
    end
  end

  def reset_buffers
    self.move_selections = []
    self.joiners = []
  end

  def full_round?
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
