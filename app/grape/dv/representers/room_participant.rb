module DV
  module Representers
    class RoomParticipant < Grape::Roar::Decorator
      include DV::Representers::Base

      property :uuid
      property :user_uuid

      link :self do |opts|
        build_url(opts,"/dv/room_participant/#{uuid}")
      end
    end
  end
end
