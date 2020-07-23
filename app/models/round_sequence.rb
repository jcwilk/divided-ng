# This orchestrates Rounds leading into other Rounds
# It has a queue for RoomParticipants joining into the next round
# It hands them off to rounds to become RoundParticipants

class RoundSequence
  class NotStartedError < StandardError; end
  class AlreadyStartedError < StandardError; end

  attr_reader :uuid

  def initialize
    @uuid = SecureRandom.uuid
    self.rounds = []
    reset_move_selections
  end

  def start(**args)
    assert_not_started

    rounds << Round.start(**args)
  end

  def current_round
    assert_started

    rounds.last
  end

  def advance(room_participants:, room:)
    assert_started

    rounds << current_round.advance(
      room_participants: room_participants,
      move_selections: move_selections,
      room: room
    )

    reset_move_selections
  end

  def started?
    rounds.present?
  end

  private

  attr_accessor :rounds, :move_selections

  def reset_move_selections
    self.move_selections = []
  end

  def assert_started
    raise NotStartedError if !started?
  end

  def assert_not_started
    raise AlreadyStartedError if started?
  end
end
