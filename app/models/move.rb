class Move < Hashie::Dash
  IDLE_ACTION = "wait"

  property :uuid
  property :x, required: true
  property :y, required: true
  property :action, required: true

  def initialize(**args)
    super
    self.uuid = SecureRandom.uuid
  end

  def coord
    Coord.new(x, y)
  end
end
