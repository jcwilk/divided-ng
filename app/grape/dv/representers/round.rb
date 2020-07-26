module DV
  module Representers
    class Round < Grape::Roar::Decorator
      include DV::Representers::Base

      property :uuid

      link :self do |opts|
        build_url(opts,"/dv/round/#{uuid}")
      end

      collection :participants, extend: DV::Representers::Participant, as: :participants, embedded: true
    end
  end
end
