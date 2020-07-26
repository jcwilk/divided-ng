class Room < MemoryModel
  class << self
    def all
      @all||= [new]
    end

    def by_uuid(uuid)
      all.find {|r| r.uuid == uuid }
    end

    def reset
      @all = [new]
    end
  end

  delegate :current_round, to: :round_sequence

  attr_reader :participants

  def initialize
    super
    self.round_sequence = RoundSequence.new
    self.floor = Floor.new
    @participants = []
  end

  def advance
    round_sequence.advance(room_participants: participants)
  end

  def join(user)
    participants << RoomParticipant.new(user, floor: floor, room_uuid: uuid)
  end

  private

  attr_accessor :round_sequence, :floor
end
