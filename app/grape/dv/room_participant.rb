module DV
  class RoomParticipant < Grape::API
    format :json

    namespace :room_participants do
      route_param :uuid do
        desc 'Get one room participant.'
        params do
          requires :uuid, type: String, desc: 'Room participant uuid'
        end

        get do
          if RoomParticipant.has_uuid?(params[:uuid])
            present RoomParticipant.by_uuid(params[:uuid]), with: DV::Representers::RoomParticipant
          else
            error! 'Room participant not found!', 404
          end
        end
      end
    end
  end
end
