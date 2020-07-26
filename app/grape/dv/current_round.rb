module DV
  class CurrentRound < Grape::API
    format :json

    namespace :rooms do
      route_param :room_uuid do
        namespace :current_round do
          desc 'Get current round.'
          get do
            room = ::Room.by_uuid(params[:room_uuid])

            if room.nil?
              return_no_content
              status 404
            else
              present room.current_round, with: DV::Representers::Round
            end
          end
        end
      end
    end
  end
end
