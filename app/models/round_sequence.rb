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
  end

  def start(**args)
    assert_not_started

    rounds << Round.start(**args)
  end

  def current_round
    assert_started

    rounds.last
  end

  def advance
    assert_started

    rounds << current_round.advance
  end

  def started?
    rounds.present?
  end

  private

  attr_accessor :rounds

  def assert_started
    raise NotStartedError if !started?
  end

  def assert_not_started
    raise AlreadyStartedError if started?
  end
end
