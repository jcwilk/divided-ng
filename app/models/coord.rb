class Coord
  delegate :hash, to: :array

  def initialize(x, y)
    self.array = [x, y]
  end

  def x
    array.first
  end

  def y
    array.second
  end

  def ==(other)
    hash == other.hash
  end
  alias_method :eql?, :==

  private

  attr_accessor :array
end
