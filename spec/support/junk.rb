# A junkdrawer of factories
# Simple solution to factories until I need something more complex

module Junk
  def self.user
    User.new
  end

  def self.room
    Room.new
  end

  def self.floor
    Floor.new
  end

  def self.room_participant(user: Junk.user)
    RoomParticipant.new(user, floor: floor)
  end

  def self.round(room_participant: Junk.room_participant)
    Round.start.advance(room_participant: room_participant)
  end

  def self.move
    MoveGenerator::Join.call
  end

  def self.round_participant(room_participant = Junk.room_participant, move: Junk.move)
    RoundParticipant.new(room_participant, move: move)
  end
end
