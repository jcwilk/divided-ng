class Round < MemoryModel
  attr_accessor :participants
  private :participants=

  def self.start
    new(
      participants: []
    )
  end

  def initialize(participants:)
    raise "participants which haven't been finalized passed into a new round!" if !participants.all?(&:finalized?)

    self.participants_relation = HasMany.new(RoundParticipant, members: participants, indices: [:user_uuid])

    super()
  end

  def advance(room_participants:, move_selections: [])
    self.class.new(
      participants: next_participants(
        room_participants: room_participants,
        move_selections: move_selections
      )
    )
  end

  def participants
    participants_relation.all
  end

  def participant_by_user_uuid(user_uuid)
    participants_relation.by(:user_uuid, user_uuid)
  end

  def moves_by_user_uuid(user_uuid)
    participant_by_user_uuid(user_uuid).moves
  end

  private

  attr_accessor :participants_relation

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
    room_participants.select { |p| participating_user_uuid?(p.user_uuid) }.map do |room_participant|
      move_selection = move_selections.find { |ms| ms.user_uuid == room_participant.user_uuid }
      old_round_participant = participant_by_user_uuid(room_participant.user_uuid)

      selected_move = if move_selection
          old_round_participant.move_by_uuid(move_selection.move_uuid)
        else
          old_round_participant.move_by_action(Move::IDLE_ACTION)
        end

      RoundParticipant.new(
        room_participant,
        move: selected_move
      )
    end
  end

  def joining_participants(room_participants:)
    room_participants.reject { |p| participating_user_uuid?(p.user_uuid) }.map do |room_participant|
      RoundParticipant.new(
        room_participant,
        move: MoveGenerator::Join.call
      )
    end
  end

  def participating_user_uuid?(user_uuid)
    participants_relation.has?(:user_uuid, user_uuid)
  end
end
