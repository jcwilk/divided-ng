module DV
  class Room < Grape::API
    format :json

    namespace :room do
      route_param :uuid do
        desc 'Get one room.'
        params do
          requires :uuid, type: String, desc: 'Room uuid'
        end

        get do
          if ::Room.has_uuid?(params[:uuid])
            present ::Room.by_uuid(params[:uuid]), with: DV::Representers::Room
          else
            error! 'Room not found!', 404
          end
        end
      end
    end
  end
end
