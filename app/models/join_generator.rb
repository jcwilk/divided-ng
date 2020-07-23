class JoinGenerator
  def self.call(participant)
    Move.new(x: 0, y: 0, action: "join")
  end
end
