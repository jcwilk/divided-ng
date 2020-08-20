# frozen_string_literal: true

require 'rails_helper'

describe DVChannel, type: :channel do
  def last_broadcast_json(stream)
    Hashie::Mash.new(JSON.parse(broadcasts(stream).last))
  end

  context "when subscribed to a room's current_round" do
    let(:room) { Junk.room }
    let(:user) { Junk.user }

    it "streams new rounds as they come" do
      stub_connection current_user: user

      subscribe key: "dv_room_#{room.uuid}_current_round"

      room.advance

      broadcasted_round = last_broadcast_json("dv_room_#{room.uuid}_current_round")

      expect(broadcasted_round.uuid).to eq room.current_round.uuid
    end
  end
end
