require "rails_helper"

describe RoundSequence do
  subject { described_class.new(room_uuid: Junk.room.uuid, room_participants: room_participants) }

  let(:user) { Junk.user }
  let(:room_participant) { Junk.room_participant(user: user) }
  let(:room_participants) { [] }

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
      room_participants << room_participant
      subject.advance #(room_participants: [room_participant])
    end

    it "assigns a new round" do
      expect { advance }.to change { subject.current_round.uuid }
    end

    it "uses the passed participant" do
      advance

      expect(subject.current_round.participants.map(&:user_uuid)).to include(user.uuid)
    end
  end

  context "when adding a move selection" do
    let!(:pack) { Junk.round_pack }
    let!(:user2) { Junk.user.tap { |u| room.join(u); room.advance } }

    let(:user_uuid) { pack[:user].uuid }
    let(:move_uuid) { pack[:moves].first.uuid }
    let(:room) { pack[:room] }
    let(:round_sequence) { room.send(:round_sequence) }
    let(:move_selection) { MoveSelection.new(user_uuid: user_uuid, move_uuid: move_uuid) }
    let(:room_participants) { room.participants }

    def add_selection
      round_sequence.add_selection(move_selection)
    end

    it "does not raise" do
      expect { add_selection }.not_to raise_error
    end

    context "when adding the same selection twice" do
      it "raises the second time" do
        add_selection
        expect { add_selection }.to raise_error
      end
    end

    context "when a move has been selected for every participant" do
      it "advances the round" do
        move2 = room.current_round.participants.find {|p| p.user_uuid == user2.uuid }.moves.first
        move_selection2 = MoveSelection.new(user_uuid: user2.uuid, move_uuid: move2.uuid )
        round_sequence.add_selection(move_selection2)
        expect { add_selection }.to change { room.current_round }
      end
    end

    context "when a move has been made for not all participants" do
      it "does not advance the round" do
        expect { add_selection }.not_to change { room.current_round }
      end
    end
  end
end
