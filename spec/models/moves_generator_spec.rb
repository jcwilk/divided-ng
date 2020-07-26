require "rails_helper"

describe MovesGenerator do
  let(:player_coords) { Coord.new(0, 0) }
  let(:last_player_move) { Move.new(action: Move::IDLE_ACTION, x: player_coords.x, y: player_coords.y) }
  let(:player) { Junk.round_participant(move: last_player_move) }
  let(:participants) { [player] }

  let(:gen) { described_class.new(player, participants: participants) }

  describe "moves" do
    subject { gen.call }

    it "has a wait move keeping the player stationary" do
      has_wait = subject.any? do |m|
        m.action == "wait" &&
          m.coord == player.coord
      end
      expect(has_wait).to eq true
    end

    it "does not include out of bounds moves" do
      expect(subject.any? {|m| m.x == -1 && m.y == -1 }).to eql(false)
    end

    it "returns moves in a consistent order" do
      expect(subject.map(&:action)).to eql(gen.call.map(&:action))
    end

    it "does not include the spot they stand on aside from wait" do
      expect(subject.any? { |m| m.action != "wait" && [m.x, m.y] == [0,0] }).to eql(false)
    end

    context "for someone in the corner" do
      it "does not include out of bound spots" do
        expect(subject.any? { |m| m.x == -1 }).to eql(false)
      end
    end

    context "for someone in the middle" do
      let(:player_coords) { Hashie::Mash.new(x: 5, y: 5) }

      it "includes a full radius around them" do
        expect(subject.size).to eql(49)
      end
    end

    describe "with a nearby opponent" do
      let(:enemy_coords) { Coord.new(2, 2) }
      let(:last_enemy_move) { Move.new(action: Move::IDLE_ACTION, x: enemy_coords.x, y: enemy_coords.y) }
      let(:enemy) { Junk.round_participant(move: last_enemy_move) }
      let(:participants) { [player, enemy] }

      it "does not include actions for the enemy occupied tile" do
        expect(subject.any? {|m| m.x == 2 && m.y == 2 }).to eql(false)
      end

      it "does not return moves on the other side of the enemy" do
        pending "need to integrate a collision simulator"
        expect(subject.any? {|m| m.x == 3 && m.y == 3 }).to eql(false)
      end

      context "when the enemy is not adjacent" do
        it "does not include attack actions for the tiles adjacent to the enemy" do
          pending "need to change behavior when near an enemy"
          expect(subject.any? {|m| m.x == 1 && m.y == 3 && m.action == 'attack' }).to eql(false)
        end
      end

      context "when the enemy is adjacent" do
        let(:player_coords) { Coord.new(1,1) }

        it "includes attack actions for the tiles adjacent to the enemy" do
          expect(subject.any? {|m| m.x == 1 && m.y == 3 && m.action == 'attack' }).to eql(true)
        end

        it "does not include run actions for the tiles adjacent to the enemy" do
          expect(subject.any? {|m| m.x == 1 && m.y == 2 && m.action == 'run' }).to eql(false)
        end

        it "only includes adjacent run actions" do
          pending "need to lower radius to 1 when there's an adjacent enemy"
          expect(subject.any? {|m| m.action == 'run' && ((m.x - 1).abs > 1 || (m.y - 1).abs > 1) }).to eql(false)
        end
      end
    end
  end
end
