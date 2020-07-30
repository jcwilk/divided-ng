class Move < MemoryModel
  IDLE_ACTION = "wait"

  property :x, required: true
  property :y, required: true
  property :action, required: true
  private :x=, :y=, :action=

  def coord
    Coord.new(x, y)
  end
end
