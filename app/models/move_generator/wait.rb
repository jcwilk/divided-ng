class MoveGenerator
  class Wait < MoveGenerator
    def self.call(participant, coord)
      Move.new(
        x: coord.x,
        y: coord.y,
        action: Move::IDLE_ACTION,
        allow_round_participant_uuid: participant.uuid
      )
    end
  end
end
