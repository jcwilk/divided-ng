# frozen_string_literal: true

class MoveChooser
  def self.call(move, user_uuid)
    round_participant = move.participant

    raise "user uuid mismatch!" if user_uuid != round_participant.user_uuid

    room = round_participant.room
    round = round_participant.round

    raise "move is from out of date round!" if room.current_round != round

    room.choose_move(move_uuid: move.uuid, user_uuid: user_uuid)
  end
end
