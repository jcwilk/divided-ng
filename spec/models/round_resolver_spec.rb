# frozen_string_literal: true

require "rails_helper"

describe RoundResolver do
  context "when two players are trying to move to the same spot" do
    let(:pack) { Junk.round_pack_with_two_nearby_players }
    let(:user_uuid1) { pack.user1.uuid }
    let(:user_uuid2) { pack.user2.uuid }
    let(:move1) { pack.moves1.find { |move| move.coord == Coord.new(1,1) } }
    let(:move2) { pack.moves2.find { |move| move.coord == Coord.new(1,1) } }
    let(:move_selection1) { MoveSelection.new(move_uuid: move1.uuid, user_uuid: user_uuid1) }
    let(:move_selection2) { MoveSelection.new(move_uuid: move2.uuid, user_uuid: user_uuid2) }
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
      expect(participant2.coord).to eq Coord.new(0,0)
    end
  end
end
