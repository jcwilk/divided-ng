# frozen_string_literal: true

require 'rails_helper'

describe 'divided hypermedia' do
  #TODO: as this grows, split it into separate files

  def client(url = 'http://api.example.com/dv')
    @client ||= HyperResource.new(
      root: url,
      faraday_options: {
        builder: Faraday::RackBuilder.new do |builder|
          builder.request :url_encoded
          builder.adapter :rack, app
        end
      }
    )
  end

  def signed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash).signed
  end

  def first_room
    client.dv_rooms.first
  end

  def current_round
    first_room.dv_current_round
  end

  def available_moves(uuid)
    p = get_participant_by_uuid(uuid)
    fail "Participant not found!" if p.nil?
    p.moves.to_a
  end

  def get_participant_by_uuid(uuid)
    current_round.participants.find {|p| p.user_uuid == uuid }
  end

  def get_signed_in_user
    get "/"
    # For some stupid reason request specs don't forward-on signed cookies?
    signed_cookies_hash = signed_cookies
    allow_any_instance_of(ActionDispatch::Cookies::CookieJar).to receive(:signed).and_return(signed_cookies_hash)
    User.by_uuid(signed_cookies_hash[:user_uuid])
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
    let!(:room) { Junk.room }

    subject do
      current_round
    end

    it 'returns the round data' do
      expect(subject.uuid).to be_present
    end
  end

  context 'retrieving available moves for a player' do
    let!(:room) { Junk.room }
    let!(:user) { get_signed_in_user }

    subject do
      available_moves(user.uuid)
    end

    before do
      room.join(user)
    end

    it 'provides a list of available moves' do
      expect(subject.count).to be > 3
    end

    context 'and submitting one of them' do
      def submit_move
        post available_moves(user.uuid).first.choose.href
      end

      it 'advances the round' do
        expect { submit_move }.to change { current_round.uuid }
      end

      context "when there are other players who have made a move" do
        before do
          room.join(Junk.user)
        end

        it "advances the round" do
          expect { submit_move }.to change { current_round.uuid }
        end
      end
    end
  end

  context 'joining a room' do
    let!(:room) { Junk.room }
    let(:user_uuid) { 'bogus uuid' }

    def join_room(raise_on_failure = true)
      post first_room.dv_join.url, params: {'user_uuid' => user_uuid}
      raise if raise_on_failure && !response.successful?
    end

    context 'when the user exists' do
      let(:user_uuid) { get_signed_in_user.uuid }

      it 'adds the player to the room of the uuid in the params' do
        join_room

        expect(current_round.participants.map(&:user_uuid)).to eql([user_uuid])
      end

      context "when the room already has users playing" do
        before do
          Room.all.first.join(User.new)
        end

        it "does not advance the round" do
          expect { join_room }.not_to change { room.current_round }
        end
      end
    end

    context 'when the player does not exist' do
      it 'does not add any players' do
        expect { join_room(false) }.not_to change { current_round.participants }
      end

      it 'returns 401' do
        join_room(false)
        expect(response.status).to eql(401)
      end
    end
  end
end
