class MemoryModel
  attr_reader :uuid

  def initialize(*)
    @uuid = SecureRandom.uuid
  end
end
