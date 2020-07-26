require 'rails_helper'

describe Room do
  its(:current_round) { is_expected.to be_present }
  its(:participants) { is_expected.to be_empty }

  context "with no participants" do
    context "when advancing" do
      before do
        subject.advance
      end

      it "has a current_round with no participants" do
        expect(subject.current_round.participants).to be_empty
      end
    end
  end

  context "with a new participant" do
    let(:new_user) { Junk.user }

    before do
      subject.join(new_user)
    end

    it "the new participant has the room's uuid" do
      expect(subject.participants.first.room_uuid).to eq subject.uuid
    end

    context "when advancing" do
      before do
        subject.advance
      end

      it "has a current_round with the new participant" do
        expect(subject.current_round.participants.map(&:user_uuid)).to eq [new_user.uuid]
      end
    end
  end
end
