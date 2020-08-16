class Round < MemoryModel
  attr_accessor :participants
  private :participants=

  def self.start
    new.tap { |round| round.participants = [] }
  end

  def participants
    participants_relation.all
  end

  def participants=(new_participants)
    raise "participants already set!" if @participants_relation

    if !new_participants.all?(&:finalized?)
      raise "participants which haven't been finalized passed into a round!"
    end

    self.participants_relation = HasMany.new(
      RoundParticipant,
      members: new_participants,
      indices: [:user_uuid]
    )
  end

  def participant_by_user_uuid(user_uuid)
    participants_relation.by(:user_uuid, user_uuid)
  end

  def participating_user_uuid?(user_uuid)
    participants_relation.has?(:user_uuid, user_uuid)
  end

  def moves_by_user_uuid(user_uuid)
    participant_by_user_uuid(user_uuid).moves
  end

  def dv_hash
    DV::Representers::Round.render_hash(self)
  end

  private

  attr_writer :participants_relation

  def participants_relation
    raise "participants not yet set!" if @participants_relation.nil?

    @participants_relation
  end
end
