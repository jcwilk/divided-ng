# frozen_string_literal: true

require "rails_helper"

describe RoundResolver do
  let(:pack) { Junk.round_pack }
  let(:room_participants) { [pack.room_participant] }
  let(:selected_move) { pack.moves.first }
  let(:user) { pack.user }
  let(:move_selections) { [MoveSelection.new(move_uuid: selected_move.uuid, user_uuid: user.uuid)] }
  let(:round) { pack.round }

  subject do
    described_class.call(
      room_participants: room_participants,
      move_selections: move_selections,
      round: round
    )
  end

  context "for continuing users" do
    it "keeps the same user in the new round" do
      expect(subject.participants.first.user_uuid).to eq user.uuid
    end

    context "when they did select a move" do
      it "assigns their selected move as their move" do
        expect(subject.participants.first.move.uuid).to eq selected_move.uuid
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

  context "when two players are trying to move to the same spot" do
    let(:pack) { Junk.round_pack_with_two_nearby_players }
    let(:user_uuid1) { pack.user1.uuid }
    let(:user_uuid2) { pack.user2.uuid }
    let(:move1) { pack.moves1.find { |move| move.coord == Coord.new(1,1) } }
    let(:move2) { pack.moves2.find { |move| move.coord == Coord.new(1,1) } }
    let(:move_selection1) { MoveSelection.new(move_uuid: move1.uuid, user_uuid: user_uuid1) }
    let(:move_selection2) { MoveSelection.new(move_uuid: move2.uuid, user_uuid: user_uuid2) }
    let(:initial_coord1) { pack.round_participant1.coord }
    let(:initial_coord2) { pack.round_participant2.coord }

    subject do
      RoundResolver.call(
        room_participants: [pack.room_participant1, pack.room_participant2],
        move_selections: [move_selection1, move_selection2],
        round: pack.round
      )
    end

    it "backs them up one spot in the path each" do
      participant1 = subject.participant_by_user_uuid(user_uuid1)
      participant2 = subject.participant_by_user_uuid(user_uuid2)

      expect(participant1.coord).to eq Coord.new(2,2)
      expect(participant2.coord).to eq initial_coord2
    end
  end
end
