class MovesGenerator
  def self.call(participant:, participants:, room:)
    # TODO: do some checking about room size, other participants getting in the way, etc
    [Move.new(x: 0, y: 0, action: "wait")]
  end
end
