class Round
  attr_reader :participants, :uuid

  def self.start(room_participant:, room:) # TODO: needs to get room layout etc from room
    new(
      participants: [
        RoundParticipant.new(
          room_participant,
          move: JoinGenerator.call(room)
        )
      ],
      room: room
    )
  end

  def initialize(participants:, room:)
    @uuid = SecureRandom.uuid
    @participants = participants

    fill_in_participant_moves(room)
  end

  def join(participant)
    @participants << participant
  end

  def advance(room_participants:, move_selections:, room:)
    self.class.new(
      participants: next_participants(
        room_participants: room_participants,
        move_selections: move_selections,
        room: room
      ),
      room: room
    )
  end

  def participant_by_user_uuid(user_uuid)
    participants.find { |p| p.user_uuid == user_uuid } or raise "missing uuid"
  end

  def moves_by_user_uuid(user_uuid)
    participant_by_user_uuid(user_uuid).moves
  end

  private

  def fill_in_participant_moves(room)
    participants.each do |participant|
      participant.moves = MovesGenerator.call(
        participant: participant,
        participants: participants,
        room: room
      )
    end
  end

  def next_participants(room_participants:, move_selections:, room:)
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
        move: JoinGenerator.call(room)
      )
    end
  end
end
