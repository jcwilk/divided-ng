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
    # TODO: turn room_participants into round_participants by retrieving their
    # move from this round by uuid
    old_user_uuids = participants.map(&:user_uuid)
    old_room_participants = room_participants.select { |p| old_user_uuids.include?(p.user_uuid) }
    new_room_participants = room_participants - old_room_participants

    # TODO TODO TODO

    # Round.new.tap do |r|
    #   participants.each do |p|
    #     r.join(p)
    #   end
    # end
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
end
