module DV
  module Representers
    class Room < Grape::Roar::Decorator
      include DV::Representers::Base

      property :uuid

      link :self do |opts|
        build_url(opts,"/dv/rooms/#{uuid}")
      end

      link 'dv:current_round' do |opts|
        build_url(opts,"/dv/rooms/#{uuid}/current_round")
      end

      link 'dv:join' do |opts|
        build_url(opts,"/dv/rooms/#{uuid}/join")
      end
    end
  end
end
