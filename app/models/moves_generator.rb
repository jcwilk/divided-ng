class MovesGenerator
  def self.call(*args)
    new(*args).call
  end

  attr_accessor :others

  def initialize(subject, participants:, room:)
    self.others = participants - [subject]
    # TODO: fill our moves from room and others data
  end

  def call
    [Move.new(x: 0, y: 0, action: "wait")]
  end
end
