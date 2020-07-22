class Move < Hashie::Dash
  property :uuid
  property :x, required: true
  property :y, required: true
  property :action, required: true

  def initialize(**args)
    super
    self.uuid = SecureRandom.uuid

    raise "invalid x,y: #{properties.inspect}" if !valid?
  end

  def valid?
    x >= 0 && x <= 9 &&
    y >= 0 && y <= 9
  end

  def pos
    [x,y]
  end
end
