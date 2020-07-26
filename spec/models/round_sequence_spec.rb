require "rails_helper"

describe RoundSequence do
  let(:user) { Junk.user }
  let(:room_participant) { Junk.room_participant(user: user) }

  context "when new" do
    # its(:started?) { is_expected.to be false }

    # it "raises when interacting with rounds" do
    #   expect { subject.advance(room_participants: [room_participant]) }.to raise_error(RoundSequence::NotStartedError)
    # end

    it "already has a current_round" do
      expect(subject.current_round).to be_present
    end

    it "has no participating users" do
      expect(subject.current_round.participants).to be_empty
    end
  end

  # context "when started with a RoomParticipant" do
  #   def start
  #     subject.start(room_participant: room_participant)
  #   end

  #   before do
  #     start
  #   end

  #   its(:started?) { is_expected.to be true }

  #   it "raises if started again" do
  #     expect { start }.to raise_error(RoundSequence::AlreadyStartedError)
  #   end

  context "when advancing" do
    def advance
      subject.advance(room_participants: [room_participant])
    end

    it "assigns a new round" do
      expect { advance }.to change { subject.current_round.uuid }
    end

    it "uses the passed participant" do
      advance

      expect(subject.current_round.participants.map(&:user_uuid)).to include(user.uuid)
    end
  end
end
