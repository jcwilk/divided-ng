class MoveGenerator
  class Run < MoveGenerator
    def self.call(participant, coord)
      Move.new(
        x: coord.x,
        y: coord.y,
        action: "run",
        round_participant_uuid: participant.uuid
      )
    end
  end
end
