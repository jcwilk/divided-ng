class Move < MemoryModel
  IDLE_ACTION = "wait"

  property :x, required: true
  property :y, required: true
  property :action, required: true
  property :round_participant_uuid
  private :x=, :y=, :action=

  def coord
    Coord.new(x, y)
  end

  def participant
    RoundParticipant.by_uuid(round_participant_uuid)
  end
end
