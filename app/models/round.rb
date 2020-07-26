class Round < MemoryModel
  attr_reader :participants

  def self.start
    new(
      participants: []
    )
  end

  def initialize(participants:)
    raise "participants which haven't been finalized passed into a new round!" if !participants.all?(&:finalized?)

    super
    @participants = participants
  end

  def join(participant)
    @participants << participant
  end

  def advance(room_participants:, move_selections: [])
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

  def participating_uuids
    participants.map(&:user_uuid)
  end

  def next_participants(room_participants:, move_selections:)
    next_participants = continuing_participants(room_participants: room_participants, move_selections: move_selections)
    next_participants += joining_participants(room_participants: room_participants)

    next_participants.each do |participant|
      participant.moves = MovesGenerator.call(
        participant,
        participants: next_participants
      )
    end
  end

  def continuing_participants(room_participants:, move_selections:)
    room_participants.select { |p| participating_uuids.include?(p.user_uuid) }.map do |room_participant|
      move_selection = move_selections.find { |ms| ms.user_uuid == room_participant.user_uuid }
      old_round_participant = participants.find { |p| p.user_uuid == room_participant.user_uuid }
      selected_move = old_round_participant.moves.find do |move|
        if move_selection
          move.uuid == move_selection.move_uuid
        else
          move.action == Move::IDLE_ACTION
        end
      end

      if selected_move.nil?
        raise "failed to find selected move! #{move_selection ? "did have selection" : "did not have selection"}"
      end

      RoundParticipant.new(
        room_participant,
        move: selected_move
      )
    end
  end

  def joining_participants(room_participants:)
    room_participants.reject { |p| participating_uuids.include?(p.user_uuid) }.map do |room_participant|
      RoundParticipant.new(
        room_participant,
        move: MoveGenerator::Join.call
      )
    end
  end
end
