# frozen_string_literal: true

require 'rails_helper'

describe DVChannel, type: :channel do
  def last_broadcast_json(stream)
    Hashie::Mash.new(JSON.parse(broadcasts(stream).last))
  end

  context "when subscribed to a room's current_round" do
    let!(:pack) { Junk.round_pack }
    let(:room) { pack[:room] }
    let(:user_uuid) { pack[:user].uuid }

    it "streams new rounds as they come" do
      stub_connection user_uuid: user_uuid

      subscribe rel_path: "/dv/rooms/#{room.uuid}/current_round"

      room.advance

      broadcasted_round = last_broadcast_json("/dv/rooms/#{room.uuid}/current_round")

      expect(broadcasted_round.uuid).to eq room.current_round.uuid
    end
  end
end
