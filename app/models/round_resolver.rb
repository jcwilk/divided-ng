class RoundResolver
  include Callable

  def initialize(room_participants:, move_selections: [], round:)
    self.room_participants = room_participants
    self.move_selections = move_selections
    self.round = round
  end

  def call
    participants = generate_participants

    Round.new.tap do |next_round|
      participants.each do |participant|
        participant.round_uuid = next_round.uuid
      end

      next_round.participants = participants
    end
  end

  private

  attr_accessor :room_participants, :move_selections, :round

  delegate :participant_by_user_uuid, :participating_user_uuid?, to: :round, private: true

  def generate_participants
    next_participants = continuing_participants
    next_participants += joining_participants

    next_participants.each do |participant|
      participant.moves = MovesGenerator.call(
        participant,
        participants: next_participants
      )
    end
  end

  def continuing_participants
    room_participants.select { |p| participating_user_uuid?(p.user_uuid) }.map do |room_participant|
      move_selection = move_selections.find { |ms| ms.user_uuid == room_participant.user_uuid }
      old_round_participant = round.participant_by_user_uuid(room_participant.user_uuid)

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

  def joining_participants
    room_participants.reject { |p| participating_user_uuid?(p.user_uuid) }.map do |room_participant|
      RoundParticipant.new( # TODO: how to make a round participant and join at the same time?
        room_participant,
        move: MoveGenerator::Join.call()
      )
    end
  end
end
