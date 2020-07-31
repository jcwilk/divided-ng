module DV
  module Representers
    class Move < Grape::Roar::Decorator
      include DV::Representers::Base

      property :x
      property :y
      property :action

      link :self do |opts|
        build_url(opts,"/dv/moves/#{uuid}")
      end
    end
  end
end
