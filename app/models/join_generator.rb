class JoinGenerator
  def self.call(room)
    Move.new(x: 0, y: 0, action: "join")
  end
end
