module DV
  module Representers
    class RoundParticipant < Grape::Roar::Decorator
      include DV::Representers::Base

      property :uuid
      property :user_uuid

      link :self do |opts|
        build_url(opts,"/dv/round_participant/#{uuid}")
      end

      property :move, extend: DV::Representers::Move, embedded: true

      collection :moves, extend: DV::Representers::Move, as: :moves, embedded: true
    end
  end
end
