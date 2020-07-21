class Round
  attr_reader :participants, :uuid

  def self.start(room_participant:, room:) # TODO: needs to get room layout etc from room
    new.tap do |round|
      round.join(room_participant)
    end
  end

  def initialize
    @uuid = SecureRandom.uuid
    @participants = []
  end

  def join(participant)
    @participants << participant
  end

  def advance
    Round.new.tap do |r|
      participants.each do |p|
        r.join(p)
      end
    end
  end
end
