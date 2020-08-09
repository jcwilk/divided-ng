module DV
  module Representers
    class Room < Grape::Roar::Decorator
      include DV::Representers::Base

      curies do |opts|
        [
          name: :dvlisten,
          href: "http://github.com/divided"
        ]
      end

      property :uuid

      link :self do |opts|
        build_url(opts,"/dv/rooms/#{uuid}")
      end

      link 'dv:current_round' do |opts|
        build_url(opts,"/dv/rooms/#{uuid}/current_round")
      end

      link "dvlisten:current_round" do |opts|
        build_listen_uri(opts, DVChannel.current_round_key(room_uuid: uuid))
      end

      link 'dv:join' do |opts|
        build_url(opts,"/dv/rooms/#{uuid}/join")
      end
    end
  end
end
