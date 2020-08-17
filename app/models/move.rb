class Move < MemoryModel
  IDLE_ACTION = "wait"

  property :x, required: true
  property :y, required: true
  property :action, required: true
  property :allow_round_participant_uuid
  private :x=, :y=, :action=

  def coord
    Coord.new(x, y)
  end
end
