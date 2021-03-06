class MoveGenerator
  class Attack < MoveGenerator
    def self.call(participant, coord)
      Move.new(
        x: coord.x,
        y: coord.y,
        action: "attack",
        allow_round_participant_uuid: participant.uuid
      )
    end
  end
end
