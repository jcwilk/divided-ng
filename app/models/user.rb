# This is the core model for a player
# It holds data which follows a player from room to room
# It is only referenced by RoomParticipant
# It holds a credential mechanism based on a secret key stored in a cookie

class User < MemoryModel
end
