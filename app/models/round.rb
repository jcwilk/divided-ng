class Round
  attr_reader :participants, :uuid

  def self.start(room_participant:)
    new(
      participants: [
        RoundParticipant.new(
          room_participant,
          move: JoinGenerator.call(room_participant)
        )
      ]
    )
  end

  def initialize(participants:)
    @uuid = SecureRandom.uuid
    @participants = participants

    fill_in_participant_moves
  end

  def join(participant)
    @participants << participant
  end

  def advance(room_participants:, move_selections:)
    self.class.new(
      participants: next_participants(
        room_participants: room_participants,
        move_selections: move_selections
      )
    )
  end

  def participant_by_user_uuid(user_uuid)
    participants.find { |p| p.user_uuid == user_uuid } or raise "missing uuid"
  end

  def moves_by_user_uuid(user_uuid)
    participant_by_user_uuid(user_uuid).moves
  end

  private

  def fill_in_participant_moves
    participants.each do |participant|
      # TODO: fix this circular reference - shouldn't need participants to fill out the same participants
      participant.moves = MovesGenerator.call(
        participant,
        participants: participants
      )
    end
  end

  def next_participants(room_participants:, move_selections:)
    continuing_user_uuids = participants.map(&:user_uuid)
    continuing_room_participants = room_participants.select { |p| continuing_user_uuids.include?(p.user_uuid) }

    next_participants = continuing_room_participants.map do |room_participant|
      move_selection = move_selections.find { |ms| ms.user_uuid == room_participant.user_uuid }
      old_round_participant = participants.find { |p| p.user_uuid == room_participant.user_uuid }
      selected_move = old_round_participant.moves.find do |m|
        if move_selection
          m.uuid == move_selection.move_uuid
        else
          m.action == Move::IDLE_ACTION
        end
      end

      RoundParticipant.new(
        room_participant,
        move: selected_move
      )
    end

    new_room_participants = room_participants - continuing_room_participants

    next_participants += new_room_participants.map do |room_participant|
      RoundParticipant.new(
        room_participant,
        move: JoinGenerator.call(room_participant)
      )
    end
  end
end
