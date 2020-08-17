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

  def self.room_participant(user: Junk.user, room: Junk.room)
    RoomParticipant.new(user, floor: floor, room_uuid: room.uuid)
  end

  def self.round(room_participant: Junk.room_participant)
    RoundResolver.call(
      room_participants: [room_participant],
      round: Round.start
    )
  end

  def self.move
    MoveGenerator::Join.call
  end

  def self.round_participant(room_participant = Junk.room_participant, move: Junk.move)
    RoundParticipant.new(room_participant, move: move)
  end

  def self.round_pack
    room = Junk.room
    user = Junk.user
    room_participant = room.join(user)
    room.advance
    round_participant = room.current_round.participants.first

    {
      room: room,
      user: user,
      room_participant: room_participant,
      round: room.current_round,
      round_participant: round_participant,
      moves: round_participant.moves
    }.extend(Hashie::Extensions::MethodReader)
  end

  def self.round_pack_with_two_nearby_players
    room = Junk.room
    user1 = Junk.user
    user2 = Junk.user

    # round 1
    room_participant1 = room.join(user1)

    # round 2
    room_participant2 = room.join(user2)
    user1_moves = room.current_round.participants.first.moves
    move = user1_moves.find { |move| move.x == 3 && move.y == 3 }
    room.choose_move(move_uuid: move.uuid, user_uuid: user1.uuid)


    # round 3
    round = room.current_round
    round_participant1 = room.current_round.participants.find { |p| p.user_uuid == user1.uuid }
    round_participant2 = (room.current_round.participants - [round_participant1]).first

    {
      room: room,
      user1: user1,
      user2: user2,
      room_participant1: room_participant1,
      room_participant2: room_participant2,
      round: round,
      round_participant1: round_participant1,
      round_participant2: round_participant2,
      moves1: round_participant1.moves,
      moves2: round_participant2.moves,
    }.extend(Hashie::Extensions::MethodReader)
  end
end
