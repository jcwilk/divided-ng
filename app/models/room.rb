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

  delegate :current_round, :advance, to: :round_sequence

  def initialize
    super
    self.round_sequence = RoundSequence.new

    # TODO: Something feels off about this, we shouldn't have to
    # manaully start it until someone joins because we want EM to
    # be advancing it every X seconds while people are in it, but
    # there should always be a current round. Once we integrate
    # EM the optimal form should be clearer
    # round_sequence.start(room_participants: [])
  end

  private

  attr_accessor :round_sequence
end
