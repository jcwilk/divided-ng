require "rails_helper"

describe RoundSequence do
  let(:user) { Junk.user }
  let(:room_participant) { Junk.room_participant(user: user) }

  context "when new" do
    its(:started?) { is_expected.to be false }

    it "raises when interacting with rounds" do
      expect { subject.advance(room_participants: [room_participant]) }.to raise_error(RoundSequence::NotStartedError)
    end
  end

  context "when started with a RoomParticipant" do
    def start
      subject.start(room_participant: room_participant)
    end

    before do
      start
    end

    its(:started?) { is_expected.to be true }

    it "returns a new round containing the RoomParticipant" do
      round = subject.current_round
      expect(round.participants.map(&:user_uuid)).to include(user.uuid)
    end

    it "raises if started again" do
      expect { start }.to raise_error(RoundSequence::AlreadyStartedError)
    end

    context "when advancing" do
      def advance
        subject.advance(room_participants: [room_participant])
      end

      it "assigns a new round" do
        expect { advance }.to change { subject.current_round.uuid }
      end
    end
  end
end
