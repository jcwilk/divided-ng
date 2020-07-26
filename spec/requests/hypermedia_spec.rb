require 'rails_helper'

describe 'divided hypermedia' do
  #TODO: as this grows, split it into separate files

  def client(url = 'http://api.example.com/dv')
    HyperResource.new(
      root: url,
      faraday_options: {
        builder: Faraday::RackBuilder.new do |builder|
          builder.request :url_encoded
          builder.adapter :rack, app
        end
      }
    )
  end

  describe 'utlities' do
    describe 'rendering an object' do
      subject { DV::Representers::Round.render(Junk.round) }

      it 'returns a JSON hash' do
        expect(JSON.parse(subject).class).to eql(Hash)
      end

      it 'includes the canonical hostname' do
        expect(subject).to include(Divided::CANONICAL_HOST.chomp(":80")) #chomp off :80 cause the libs do too
      end
    end
  end

  context 'retrieving the current round data for a room' do
    subject do
      client.rooms.first.current_round
    end

    it 'returns the round data' do
      expect(subject.uuid).to be_present
    end
  end

  context 'retrieving available moves for a player' do
    #em_around

    before do
      @player = Round.new_player
      Timecop.travel(Time.now+Round::ROUND_DURATION+1)
    end

    subject do
      available_moves(@player.uuid)
    end

    it 'provides a list of available moves' do
      finish_after_round do
        expect(subject.count).to be > 3
      end
    end

    context 'and submitting one of them' do
      def submit_move
        available_moves(@player.uuid).first.post
      end

      it 'advances the round' do
        finish_after_round do
          expect{ submit_move }.to change { Round.current_number }.by(1)
        end
      end
    end
  end

  context 'joining a room' do
    let(:player_uuid) { 'puuid' }

    #em_around

    def join_room
      post first_room.dv_join.url, nil, {'uuid' => player_uuid}
    end

    context 'when the player exists' do
      before do
        Player.new_active(player_uuid)
      end

      it 'adds the player to the room of the uuid in the header' do
        join_room
        finish_after_round do
          expect(current_round.participants.map(&:uuid)).to eql([player_uuid])
        end
      end
    end

    context 'when the player does not exist' do
      it 'does not add any players' do
        join_room
        finish_after_round do
          expect(current_round.participants.size).to eql(0)
        end
      end

      it 'returns 404' do
        join_room
        expect(response.status).to eql(404)
      end
    end
  end
end
