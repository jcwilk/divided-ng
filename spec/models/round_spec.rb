require 'rails_helper'

describe Round do
  let(:room) { Room.new }
  let(:user) { User.new }
  let(:participant) { RoomParticipant.new(user) }

  def start
    Round.start(room_participant: participant, room: room)
  end

  describe "Round.start" do
    subject { start }

    it "has the passed participant as the only participant" do
      expect(subject.participants.map(&:user_uuid)).to eq [user.uuid]
    end

    it "has join as the participant's action" do
      expect(subject.participant_by_user_uuid(user.uuid).move.action).to eq "join"
    end

    it "has moves available for the participant" do
      expect(subject.moves_by_user_uuid(user.uuid)).to be_present
    end
  end

  describe "advance" do
    subject { round.advance(room_participants: [participant], room: room) }

    let(:round) { start }


  end
end
