# This is a wrapper around a user
# It is created when a user joins a room
# It is primarily tracked by the room, but also by the round participant
# It holds data about the user which only concerns the room (eg, their position, various room specific states)
# The data it holds does not follow the player as they leave the room

class RoomParticipant
  attr_reader :uuid, :floor, :room_uuid

  delegate :uuid, to: :user, prefix: true

  def initialize(user, floor:, room_uuid:)
    self.user = user
    @floor = floor
    @room_uuid = room_uuid
    @uuid = SecureRandom.uuid
  end

  private

  attr_accessor :user
end
