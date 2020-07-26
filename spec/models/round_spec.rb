require 'rails_helper'

describe Round do
  let(:room) { Junk.room }
  let(:user) { Junk.user }
  let(:participant) { Junk.room_participant(user: user) }

  def start
    Round.start
  end

  describe "Round.start" do
    subject { start }

    it "has no participants" do
      expect(subject.participants).to be_empty
    end
  end

  describe "advance" do
    subject { round.advance(room_participants: room_participants, move_selections: move_selections) }

    let(:room_participants) { [participant] }
    let(:move_selections) { [MoveSelection.new(move_uuid: selected_move.uuid, user_uuid: user.uuid)] }
    let(:selected_move) { round.moves_by_user_uuid(user.uuid).first }
    let(:round) { start.advance(room_participants: [participant]) }

    context "for continuing users" do
      it "keeps the same user in the new round" do
        expect(subject.participants.first.user_uuid).to eq user.uuid
      end

      context "when they did select a move" do
        it "assigns their selected move as their move" do
          expect(subject.participants.first.move).to eq selected_move
        end
      end

      context "when they did not select a move" do
        let(:move_selections) { [] }

        it "assigns the idle action as their move" do
          expect(subject.participants.first.move.action).to eq Move::IDLE_ACTION
        end
      end
    end

    context "for disconnecting users" do
      let(:room_participants) { [] }

      it "does not include the user in the new round" do
        expect(subject.participants).to be_empty
      end
    end

    context "for joining users" do
      let(:new_user) { Junk.user }
      let(:new_participant) { Junk.room_participant(user: new_user) }
      let(:room_participants) { super() + [new_participant] }

      it "has the joining participant included in the participants" do
        expect(subject.participants.map(&:user_uuid)).to include new_user.uuid
      end

      it "has join as the participant's action" do
        expect(subject.participant_by_user_uuid(new_user.uuid).move.action).to eq "join"
      end

      it "has moves available for the participant" do
        expect(subject.moves_by_user_uuid(user.uuid)).to be_present
      end
    end
  end

  describe "select_move"

  describe "valid_move_selection?"
end
