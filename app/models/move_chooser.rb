# frozen_string_literal: true

class MoveChooser
  include Callable

  def initialize(move, user_uuid)
    self.move = move
    self.user_uuid = user_uuid
  end

  def call
    if !authorized?
      raise "wrong user!"
    end

    if !current_round?
      raise "out of date round!"
    end

    room.choose_move(move_uuid: move.uuid, user_uuid: user_uuid)
  end

  private

  attr_accessor :move, :user_uuid

  delegate :allow_round_participant_uuid, to: :move, private: true

  def authorized?
    return false if allow_round_participant_uuid.nil?

    return false if round_participant.user_uuid != user_uuid

    return true
  end

  def current_round?
    return false if room.current_round != round_participant.round

    return true
  end

  def round_participant
    @round_participant ||= RoundParticipant.by_uuid(allow_round_participant_uuid)
  end

  def room
    round_participant.room
  end
end
